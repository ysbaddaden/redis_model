require 'rubygems'
require 'bundler/setup'
Bundler.setup(:default)

require_relative '../lib/redis_model'
require_relative 'models/post.rb'
require_relative 'models/comment.rb'
require_relative 'models/row.rb'

require 'test/unit'

class Test::Unit::TestCase
  def assert_respond_to(object, method, message = nil)
    klass_name = object.respond_to?(:class) ? object.class.name : object.name
    message ||= "Expected #{klass_name} to respond to :#{method}"
    assert object.respond_to?(method), message
  end
end
