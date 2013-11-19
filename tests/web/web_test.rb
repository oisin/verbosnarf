$: << File.dirname(__FILE__) + "/../.."

require_relative '../helper'

SimpleCov.command_name 'Web Tests'

require 'minitest/autorun'
require 'app'

class WebAppTests < Minitest::Unit::TestCase
	def test_pass
    puts "\nWeb tests aren't implemented yet"
    assert true
  end
end