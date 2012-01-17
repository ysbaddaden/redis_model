require_relative 'test_helper'

class AssociationsTest < Test::Unit::TestCase
  def test_has_many
    assert_respond_to :comments , Post.new
    assert_respond_to :comments=, Post.new
  end

  def test_belongs_to
    assert_respond_to :post , Comment.new
    assert_respond_to :post=, Comment.new
    assert Comment.attribute_exists?(:post_id), "Comment should have a post_id attribute."
  end

  def test_belongs_to_assignment
    comment = Comment.new
    comment.post = posts(:post1)
    assert_same comment.post, posts(:post1)
    assert_equal comment.post_id, posts(:post1).id
  end

  def test_belongs_to_assignment_by_id
    comment = Comment.new(:post_id => posts(:welcome).id)
    assert_equal comment.post_id, posts(:welcome).id
    assert_equal comment.post, posts(:welcome)
  end

  def test_belongs_to_mass_assignment
    comment = Comment.new(:post => posts(:welcome))
    assert_equal comment.post_id, posts(:welcome).id
    assert_same comment.post, posts(:welcome)
  end
end
