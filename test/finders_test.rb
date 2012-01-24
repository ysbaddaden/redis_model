require_relative './test_helper'

class FindersTest < Test::Unit::TestCase
  def test_count
    assert_equal posts.size, Post.count
    assert_equal rows.size,  Row.count
  end

  def test_find
    assert_instance_of Post, Post.find(posts(:welcome).id)
    assert_nothing_raised { Post.find(posts(:welcome).id) }
    assert_nothing_raised { Post.find(posts(:post1).id) }
    assert_raises(RedisModel::RecordNotFound) { Post.find(12346890) }
  end

  def test_all
    assert_equal [ posts(:welcome).id, posts(:post1).id ], Post.all.collect(&:id)
    assert_equal [], Row.all
  end

  def test_exists?
    assert Post.exists?(posts(:welcome).id)
    refute Post.exists?(1234567890)
  end

  def test_first
    assert_equal posts(:welcome), Post.first
    assert_nil Row.first
  end

  def test_last
    assert_equal posts(:post1), Post.last
    assert_nil Row.last
  end

  def test_reload
    post = posts(:post1)
    back = Post.find(post.id)
    
    post.update_attributes(:title => "Some other title")
    assert_not_equal back.title, post.title
    
    assert_same back, back.reload
    assert_equal "Some other title", back.title
  end

  def test_find_all_by_attr_name
    assert_equal [ posts(:welcome) ], Post.find_all_by_approved(true)
    assert_equal [ posts(:post1) ],   Post.find_all_by_approved(false)
  end
end
