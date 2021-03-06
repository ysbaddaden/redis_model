require_relative './test_helper'

class PersistanceTest < ActiveSupport::TestCase
  def test_class_key
    assert_equal "Post", Post.key
    assert_equal "Row",  Row.key
    assert_equal "Post:all", Post.key(:all)
    assert_equal "Post:123", Post.key(123)
    assert_equal "Row:456",  Row.key(456)
  end

  def test_index_key
    assert_equal "Post_idx:id", Post.index_key(:id)
    assert_equal "Post_idx:url", Post.index_key("url")
  end

  def test_key
    assert_equal "Post:#{posts(:welcome).id}", posts(:welcome).key
  end

  def test_class_create
    assert_difference('Row.count') do
      row = Row.create(:name => "my secret")
      assert_instance_of Row, row
      row.reload
      assert_not_nil row.id
      assert_equal "my secret", row.name
      assert_kind_of Date, row.created_on
      assert_kind_of Date, row.updated_on
    end
    
    assert_difference('Post.count') do
      post = Post.create
      post.reload
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

  def test_update_attributes
    post = posts(:welcome)
    post.update_attributes(:title => "go away")
    assert_equal "go away", post.title
    assert_equal "go away", Post.find(post.id).title
  end

  def test_class_update
    post = Post.update(posts(:welcome).id, :title => "go away")
    assert_instance_of Post, post
    assert_equal "go away", post.title
    assert_equal "go away", Post.find(posts(:welcome).id).title
  end

#  def test_update_failure
#  end

  def test_delete
    assert_difference('Post.count', -1) do
      posts(:welcome).delete
      posts(:welcome).destroyed?
    end
    refute Post.exists?(posts(:welcome).id)
  end

  def test_class_delete
    assert_difference('Post.count', -1) do
      Post.delete(posts(:welcome).id)
    end
    refute Post.exists?(posts(:welcome).id)
  end

#  def test_delete_failure
#  end

  def test_destroy
    assert_difference('Post.count', -1) do
      post = posts(:welcome).destroy
      assert post.destroyed?
    end
    refute Post.exists?(posts(:welcome).id)
  end

  def test_class_destroy
    assert_difference('Post.count', -1) do
      post = Post.destroy(posts(:welcome).id)
      assert_instance_of Post, post
      assert post.destroyed?
    end
    refute Post.exists?(posts(:welcome).id)
  end

#  def test_destroy_failure
#  end
end
