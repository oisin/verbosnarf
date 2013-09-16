$: << File.dirname(__FILE__) + "/.."

require 'timecop'
require 'dm-aggregates'

# Produce local and Coveralls coverage
require 'coveralls'
Coveralls.wear!
SimpleCov.command_name 'Unit Tests'
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]

require 'minitest/autorun'
require 'snarfer'

class SnarferTests < Minitest::Unit::TestCase
  def setup
    LogDatabase.init("sqlite::memory:")
    @logs = []
    @logs << <<-eolog
8021ec09afa691bca04f6a84f42ef094f8c2aa698d740694b71a7f8f6e149877 verbose-ireland  37.228.196.48 - 6472D7A57DB1174F REST.GET.OBJECT 01_TheVerbosePodcast_-_Episode01.mp3 "GET /verbose-ireland/01_TheVerbosePodcast_-_Episode01.mp3 HTTP/1.1" 206 - 50984143 50984143 18523 54 "https://s3-eu-west-1.amazonaws.com/verbose-ireland/01_TheVerbosePodcast_-_Episode01.mp3" "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.31 (KHTML, like Gecko) Chrome/26.0.1410.64 Safari/537.31" -}
eolog
    @logs << <<-eolog
8021ec09afa691bca04f6a84f42ef094f8c2aa698d740694b71a7f8f6e149877 verbose-ireland  37.228.196.48 - 6472D7A57DB11750 REST.GET.OBJECT 01_TheVerbosePodcast_-_Episode01.mp3 "GET /verbose-ireland/01_TheVerbosePodcast_-_Episode01.mp3 HTTP/1.1" 206 - 50984143 50984143 18523 54 "https://s3-eu-west-1.amazonaws.com/verbose-ireland/01_TheVerbosePodcast_-_Episode01.mp3" "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.31 (KHTML, like Gecko) Chrome/26.0.1410.64 Safari/537.31" -}
eolog
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

  def test_records_activity
    now = Time.now.utc
    yesterday = now.to_date - 1
    
    # A couple of fake logs, activity should
    # indicate length of this array of logs
    # processed
    content = [
      StringIO.new(@logs[0]),
      StringIO.new(@logs[1])
    ]

    logs = MiniTest::Mock.new
    logs.expect(:with_prefix, content, ["logs/#{yesterday.strftime('%Y-%m-%d')}"])

    bucket = MiniTest::Mock.new
    bucket.expect(:objects, logs, [])

    s3 = MiniTest::Mock.new
    s3.expect(:buckets, { 'verbose-ireland' => bucket})

    Timecop.freeze(now) do
      AWS::S3.stub :new, s3 do
        s = Snarfer.new("access", "secret")

        assert_equal 0, Activity.count
        s.snarf(yesterday)
        assert_equal 1, Activity.count

        activity = Activity.first
        assert_equal 2, activity.processed
        assert_nil activity.exception

        # Comparing the following as strings to avoid
        # DateTime deep structure comparisons
        assert_equal DateTime.now.to_s, activity.start.to_s
        assert_equal DateTime.now.to_s, activity.end.to_s
      end
    end
  end  
end