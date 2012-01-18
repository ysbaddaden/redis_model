require_relative '../test_helper'

class HasManyTest < ActiveSupport::TestCase
  def test_has_many
    assert_respond_to :comments , Post.new
    assert_respond_to :comments=, Post.new
  end

  def test_getter
    assert_instance_of RedisModel::Relation, Post.new.comments
  end

  def test_push_with_persisted_records
    comments = posts(:uncommented).comments
    assert_equal 0, comments.size
    
    comments.push(Comment.create(:body => "blablabla"))
    assert_equal 1, comments.size
    assert_equal "blablabla", comments.first.body
    assert_not_nil comments.first.post_id, "foreign_key should have been populated"
    
    comments.push(Comment.create(:body => "other"))
    assert_equal 2, comments.size
    assert_equal "other", comments.last.body
    assert_not_nil comments.last.post_id, "foreign_key should have been populated"
  end

  def test_pushing_unpersisted_record_should_create_it
    comment = Comment.new(:body => "a comment")
    posts(:uncommented).comments << comment
    assert_equal 1, posts(:uncommented).comments.size
    assert comment.persisted?
  end

  def test_association_type_mismatch
    assert_nothing_raised { Post.new.comments.push(Comment.new) }
    assert_raises(RedisModel::AssociationTypeMismatch) { Post.new.comments.push(Row.new) }
  end

#  def test_mass_setter
#    flunk
#  end

  def test_to_a
    assert_equal [ comments(:welcome1) ], posts(:welcome).comments.to_a
  end

  def test_clear
    posts(:welcome).comments.clear
    assert_equal 0, posts(:welcome).comments.size
    assert_not_nil comment = Comment.find(comments(:welcome1).id)
    assert_nil comment.post_id
  end

#  def test_destroying_child_should_remove_it_from_parent_list
#    flunk
#  end

#  def test_saving_parent_should_save_child
#    flunk
#  end
end
