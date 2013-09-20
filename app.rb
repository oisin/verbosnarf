$: << File.dirname(__FILE__)

require 'sinatra'
require 'haml'

class VerboSnarferWebApp < Sinatra::Base
  configure  do
    set :public_folder, File.dirname(__FILE__) + '/views'
    set :app_file, __FILE__
    set :port, ENV['PORT']
    puts "Starting on port #{ENV['PORT']}"
  end

  get '/' do
    haml :index
  end

  run! if app_file == $0
end
