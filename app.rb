$: << File.dirname(__FILE__)

require 'snarfer'

DataMapper::Logger.new($stdout, :warn)
DataMapper.setup(:default, ENV['DATABASE_URL'])
DataMapper.finalize
DataMapper.auto_migrate!

snarfer = Snarfer.new(ENV['AWS_ACCESS_KEY'], ENV['AWS_SECRET_KEY'])

snarfer.snarf("25-05-2013")