require_relative './test_helper'

class PersistanceTest < ActiveSupport::TestCase
  def test_class_create
    assert_difference('Row.count') do
      row = Row.create(:name => "my secret")
      assert_instance_of Row, row
      assert_not_nil row.id
      assert_equal "my secret", row.name
      assert_kind_of Date, row.created_on
      assert_kind_of Date, row.updated_on
    end
    
    assert_difference('Post.count') do
      post = Post.create
      assert_not_nil post.id
      assert_kind_of Integer, post.id
      assert_kind_of Time, post.created_at
      assert_kind_of Time, post.updated_at
    end
  end

  def test_create
    assert_difference('Post.count') do
      post = Post.new
      post.create
      assert_not_nil post.id
      assert_kind_of Integer, post.id
      assert_kind_of Time, post.created_at
      assert_kind_of Time, post.updated_at
      assert Post.exists?(post.id), "Post should have been persisted"
    end
    
    assert_difference('Row.count') do
      row = Row.new
      row.create
      assert_not_nil row.id
      assert_kind_of Date, row.created_on
      assert_kind_of Date, row.updated_on
      assert Row.exists?(row.id), "Row should have been persisted"
    end
  end

#  def test_create_failure
#  end

#  def test_update
#  end

#  def test_update_failure
#  end

#  def test_delete
#  end

#  def test_delete_failure
#  end

#  def test_destroy
#  end

#  def test_destroy_failure
#  end

#  def test_class_update
#  end

#  def test_class_destroy
#  end

#  def test_class_delete
#  end
end
