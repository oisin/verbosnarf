$: << File.dirname(__FILE__) + "/.."

require 'simplecov'
SimpleCov.start 
SimpleCov.command_name 'snarfer units'

require 'minitest/autorun'
require 'snarfer'

class SnarferTests < Minitest::Unit::TestCase
  def setup
    LogDatabase.init("sqlite::memory:")
  end

  def teardown
  end

  def test_start_is_after_end
    s3 = MiniTest::Mock.new
    AWS::S3.stub :new, s3 do
      s = Snarfer.new("access", "secret")
      assert_raises(ArgumentError) {
        d = Time.now.utc.to_date
        s.snarf(d+4, d)
      }
    end
  end

  def test_can_only_snarf_in_the_past
    s3 = MiniTest::Mock.new
    AWS::S3.stub :new, s3 do
      s = Snarfer.new("access", "secret")
      assert_raises(ArgumentError) {
        s.snarf(Time.now.utc.to_date)
      }
    end
  end
end