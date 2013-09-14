require 'data_mapper'

class Download
  include DataMapper::Resource 

  property :id, Serial
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
  property :country, String
  property :region, String
  property :city, String
  property :latitude, Float
  property :longitude, Float
  property :timezone, String
  property :isp, String

  has n, :downloads
end