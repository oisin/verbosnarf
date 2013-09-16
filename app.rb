$: << File.dirname(__FILE__)

require 'snarfer'

Database.init(ENV['DATABASE_URL'])
snarfer = Snarfer.new(ENV['AWS_ACCESS_KEY'], ENV['AWS_SECRET_KEY'])
snarfer.snarf("25-05-2013")