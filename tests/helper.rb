require 'coveralls'
require 'simplecov'

require 'timecop'
require 'dm-aggregates'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]

SimpleCov.add_filter("test/*")
SimpleCov.start
