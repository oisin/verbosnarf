$: << File.dirname(__FILE__)

require 'sinatra'
require 'haml'
require 'oj'
require 'time'

class VerboSnarferWebApp < Sinatra::Base
  configure  do
    set :public_folder, File.dirname(__FILE__) + '/public'
    set :app_file, __FILE__
    set :port, ENV['PORT']
    puts "Starting on port #{ENV['PORT']}"
  end

  get '/' do
    @episodes =  ['1', '2', '3', '4'].reverse  
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
    case ep
    when '1'  
      26532
    when '2'  
      10373
    when '3'  
      24018
    when '4'   
      890
    else 0
    end
  end

  run! if app_file == $0
end
