require_relative 'test_helper'

class BaseTest < Test::Unit::TestCase
  def test_equality
    assert_equal posts(:welcome), posts(:welcome)
    assert_equal posts(:post1), posts(:post1)
    assert_not_equal posts(:post1), Comment.new
    assert_not_equal Post.new, Post.new
  end
end
