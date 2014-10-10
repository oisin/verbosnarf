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

    @bucket_name = 'verbose-ireland'
    @downloads_regex = /.* verbose-ireland \[(.*)\] (\d+.\d+.\d+.\d+) .* ([0-9A-F]+) REST.GET.OBJECT \d+_TheVerbosePodcast_-_Episode(\d+).mp3 .* \d+ - (\d+) (\d+) (\d+) (\d+) "(.*)" "(.*)" */
  end

  # Retrieve S3 logs from the range of dates provided.
  # If only one date, then just retrieve for that date.
  def snarf(start_date, end_date = nil)
    start_date = condition(start_date)
    end_date = condition(end_date)

    if (end_date.nil? or start_date.eql?(end_date))
      download_logs(start_date)
    else
      if (start_date > end_date)
        throw ArgumentError.new("Start date is after end date")
      else
        download_logs_in_range(start_date, end_date)
      end
    end
  end

  protected

  def download_logs_in_range(s, e)

  end

  def download_logs(date)
    puts("Download logs...")
    throw ArgumentError.new("Can only get logs in the past") if (date.eql?(Time.now.utc.to_date))
    activity = Activity.new({ start: Time.now.utc})
    begin
      activity.processed = download_objects(@s3.buckets[@bucket_name], 'logs/' + date.strftime("%Y-%m-%d"))
      activity.end = Time.now.utc
    rescue StandardError => e
      activity.exception = e.to_s
      raise e
    end
    activity.save
  end

  # Grab all of the objects in the logs bucket for the
  # particular date. If the date is today, then that's
  # an issue, because the logging may not be finished
  #
  def download_objects(bucket, prefix)
    puts("Download objects with prefix <#{prefix}>...")
    log_count = 0
    bucket.objects.with_prefix(prefix).each do |log|
      puts("Log found: #{log.inspect}")
        log.read.each_line do |entry|
        puts("Log read: #{entry}")
        unless (m = @downloads_regex.match(entry)).nil?
          store(
            m[3],
            DateTime.strptime(m[1], "%d/%b/%Y:%H:%M:%S %z"),
            m[2], m[4], m[7], m[10],
            (m[9].eql?('-')) ? nil : m[9]
          ) && log_count += 1
        end
      end
    end
    log_count
  end

  def store(reqid, date, ip, episode, spent, agent, refer)
    # Only make a new record if there isn't one with
    # this request id.
    puts("Storing object...")
    unless Download.first(arid: reqid)
      Download.create(
        arid: reqid,
        at: date,
        episode: episode.to_i,  # TODO: change this
        spent: spent.to_f,
        user_agent: user_agent_with_description(agent),
        ip_address: ip_record_for(ip),
        referrer: refer
      )
      puts("New download by #{refer}")
    else
      nil
    end
  end

  def user_agent_with_description(desc)
    user_agent = UserAgent.first(description: desc) || UserAgent.new({ description: desc })
    user_agent.save && user_agent
  end

  def ip_record_for(ip)
    iprecord = IpAddress.get(ip) || IpAddress.new({ ip: ip })
    iprecord.visits += 1
    iprecord.save && iprecord
  end

  def condition(date)
    (date.nil? or date.is_a?(Date)) ? date : Date.parse(date)
  end
end
