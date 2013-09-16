require 'data_mapper'

module LogDatabase
  def self.init(url=nil)
    DataMapper::Logger.new($stdout, :warn)
    DataMapper.setup(:default, url) 
    DataMapper.finalize
    DataMapper.auto_migrate!
  end
end

class Download
  include DataMapper::Resource 

  property :id, Serial
  property :arid, String, required: true      # Amazon request id
  property :at, DateTime,   required: true
  property :episode, Integer, required: true
  property :spent, Integer, required: true 
  property :referrer, Text

  belongs_to :user_agent
  belongs_to :ip_address
end

class UserAgent
  include DataMapper::Resource

  property :id, Serial
  property :description, Text

  has n, :downloads
end

class IpAddress
  include DataMapper::Resource

  property :ip, String, key: true
  property :visits, Integer, default: 0
  property :country, String
  property :region, String
  property :city, String
  property :latitude, Float
  property :longitude, Float
  property :timezone, String
  property :isp, String

  has n, :downloads
end

class Activity
  include DataMapper::Resource

  property :id, Serial
  property :start, DateTime, required: true
  property :end, DateTime, required: true
  property :downloads, Integer, default: 0
  property :exception, Text
end