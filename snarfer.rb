# Visit AWS-S3, and pull the logs for a date range. 
#
require 'aws-sdk'
require 'date'
require 'models'

class Snarfer
  def initialize(access_key, secret)
    @s3 = AWS::S3.new(
      access_key_id: access_key, 
      secret_access_key: secret,
      region: 'eu-west-1'
    )
    Download.raise_on_save_failure = true
    UserAgent.raise_on_save_failure = true
    IpAddress.raise_on_save_failure = true
  end

  # Retrieve S3 logs from the range of dates provided.
  # If only one date, then just retrieve for that date.
  def snarf(start_date, end_date = nil)
    start_date = condition(start_date)
    end_date = condition(end_date)

    if (end_date.nil? or start_date.eql?(end_date)) 
      download_logs(start_date)
    else
      throw ArgumentError.new("Start date is after end date") if (start_date > end_date)
      throw ArgumentError.new("Not implemented for ranges > 1 day :P")
    end
  end

  private

  def download_logs(date)
    throw ArgumentError.new("Can only get logs in the past") if (date.eql?(Time.now.utc.to_date))
    logkeys = download_objects('logs/' + date.strftime("%Y-%m-%d"))
  end

  # Grab all of the objects in the logs bucket for the
  # particular date. If the date is today, then that's 
  # an issue, because the logging may not be finished
  #
  def download_objects(prefix)
    bucket = @s3.buckets['verbose-ireland']
    logs = []
    unless bucket.nil?
      full_count = 0
      bucket.objects.with_prefix(prefix).each { |log|
        # New database model here and save it :D
        rg = /.* verbose-ireland \[(.*)\] (\d+.\d+.\d+.\d+) .* REST.GET.OBJECT \d+_TheVerbosePodcast_-_Episode(\d+).mp3 .* - (\d+) (\d+) (\d+) (\d+) "(.*)" "(.*)".*/
        log.read.each_line { |entry|
          unless (m = rg.match(entry)).nil?
            store(
              DateTime.strptime(m[1], "%d/%b/%Y:%H:%M:%S %z"), 
              m[2], m[3], m[6], m[9], 
              (m[8].eql?('-')) ? nil : m[8]
            )
          end
          full_count += 1
        }
      }
      puts "Stored #{full_count} download records"
    end

  end

  # Save recorded download to database
  def store(date, ip, episode, spent, agent, refer)
    iprecord = IpAddress.get(ip)
    if iprecord.nil?
      iprecord = IpAddress.new({ ip: ip })
      begin
        iprecord.save
      rescue DataMapper::SaveFailureError => e
        puts e.resource.errors.inspect
        raise e
      end
    end

    useragent = UserAgent.first(description: agent)
    if useragent.nil?
      useragent = UserAgent.new({ description: agent })
      begin
        useragent.save
      rescue DataMapper::SaveFailureError => e
        puts e.resource.errors.inspect
        raise e
      end
    end

    begin
      d = Download.create(
        at: date, 
        episode: episode.to_i, 
        spent: spent.to_f,
        user_agent: useragent,
        ip_address: iprecord,
        referrer: refer
      )
    rescue DataMapper::SaveFailureError => e
      puts e.resource.errors.inspect
      raise 
    end
  end

  def find_bucket(name)
    @s3.buckets.each { |b|
      return b if (b.name.eql?(name))
    }
    nil 
  end

  def condition(date)
    (date.nil? or date.is_a?(Date)) ? date : Date.parse(date)
  end
end