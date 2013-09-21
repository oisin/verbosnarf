source 'https://rubygems.org'

gem 'aws-sdk', '~> 1.19.0'
gem 'datamapper'
gem 'dm-postgres-adapter'
gem 'rake'
gem 'sinatra', '~> 1.4.3'
gem 'haml'
gem 'oj'

# Using thin because it has more applicability on more cloud
# plaforms, eschewing unicorn, etc.
gem 'thin'

group :development do
  gem 'debugger'
end

group :test do
  gem 'dm-sqlite-adapter'
  gem 'minitest', '~> 3.0'
  gem 'coveralls', require: false
  gem 'timecop'
end
