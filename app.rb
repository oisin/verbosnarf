$: << File.dirname(__FILE__)

require 'sinatra'
require 'haml'
require 'oj'
require 'time'
require 'date'
require 'sucker_punch'
require 'rufus-scheduler'
require_relative './models'
require_relative './snarfer'

class SnarfJob
  include SuckerPunch::Job
  def perform(date)
    snarfer = Snarfer.new(ENV['VS_AWS_ACCESS'], ENV['VS_AWS_SECRET'])
    snarfer.snarf(date)
  end
end

class VerboSnarferWebApp < Sinatra::Base
  configure  do
    set :public_folder, File.dirname(__FILE__) + '/public'
    set :app_file, __FILE__
    set :port, ENV['PORT']
    enable :logging
    puts "Starting on port #{ENV['PORT']}"
  end

  configure :production, :development do
    LogDatabase.init(ENV['VS_DB_URL'] || "sqlite3://#{File.dirname(__FILE__)}/verbosnarf.sqlite3")

    scheduler = Rufus::Scheduler.new

    if production?
      # Production mode - run every morning 6am server time
      scheduler.cron('0 6 * * *') do
        # At 6am go do the thing
        SnarfJob.new.async.perform(Date.today - 1)
      end
    else
      # Development mode - run in 10 seconds
      scheduler.in('10s') do
        puts("About to snarf...")
        SnarfJob.new.async.perform(Date.today - 1)
      end
    end
  end

  get '/' do
    @episodes =  ['1', '2', '3', '4', '5'].reverse  
    haml :index
  end

  get '/data/:episode' do
    puts "Looking for data on episode #{params[:episode]}"  
    callback = params['callback']

    startx = Time.now.utc.to_date.to_time.to_i
    result = []
    30.times { |count| 
      result << { 'x' => startx + (count * 86400), 'y' => rand(20..256) }
    }
    Oj.dump(result)
  end

  def download_count(ep)
    0
  end

  run! if app_file == $0
end
