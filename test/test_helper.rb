RACK_ENV ||= 'test'
require 'bundler/setup'
Bundler.setup(:default, RACK_ENV)

require_relative '../lib/redis_model'
require_relative 'models/post.rb'
require_relative 'models/comment.rb'
require_relative 'models/row.rb'

require 'logger'
require 'minitest/unit'
require 'test/unit'
require 'turn'
require 'redis'
require_relative '../lib/redis_model/fixtures'

RedisModel.connection = Redis.new(
  :path => File.expand_path("../redis.sock", __FILE__),
  :logger => Logger.new(File.expand_path("../test.log", __FILE__))
)

class Test::Unit::TestCase
  def self.fixtures_path
    File.expand_path("../fixtures", __FILE__)
  end

  def setup
    RedisModel.connection.flushdb
    self.class.load_fixtures
  end

  def assert_respond_to(method, object, message = nil)
    message ||= "Expected #{object} to respond to :#{method}"
    assert object.respond_to?(method), message
  end
end
