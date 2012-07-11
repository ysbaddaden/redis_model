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

  def test_find_all
    assert_equal [ posts(:welcome), posts(:post1) ], Post.find(:all)
    assert_equal [], Row.find(:all)
  end

  def test_find_all_with_index
    assert_equal [ posts(:welcome) ], Post.find(:all, :index => [ :approved, true ])
    assert_equal [ posts(:post1) ],   Post.find(:all, :index => [ :approved, false ])
  end

  def test_find_all_with_conditions
    assert_equal [ posts(:welcome) ],
      Post.find(:all, :conditions => { :approved => true })

    assert_equal [ products(:keyboard), products(:mouse) ],
      Product.find(:all, :conditions => { :price => 9.99 })

    assert_equal [ products(:keyboard), products(:mouse) ],
      Product.find(:all, :conditions => { :price => 9.99, :currency => "EUR" })
  end

  def test_find_all_with_select
    posts = Post.find(:all, :select => [ :id, :title ])
    assert_equal [ posts(:welcome).id, posts(:post1).id ], posts.collect(&:id)
    assert_equal [ posts(:welcome).title, posts(:post1).title ], posts.collect(&:title)
    assert_equal [ nil, nil ], posts.collect(&:body)
  end

  def test_find_all_with_order
    assert_equal [ posts(:post1), posts(:welcome) ], Post.find(:all, :by => :title)
  end

  def test_find_all_with_limit
    assert_equal [ posts(:welcome).id ], Post.find(:all, :limit => [0, 1]).collect(&:id)
    assert_equal [ posts(:post1).id ], Post.find(:all, :limit => [1, 1]).collect(&:id)
  end

  def test_find_first
    assert_equal posts(:welcome), Post.find(:first)
  end

  def test_find_last
    assert_equal posts(:post1), Post.find(:last)
  end

  def test_find_first_with_order
    assert_equal posts(:post1),   Post.find(:first, :by => :id, :order => :desc)
    assert_equal posts(:post1),   Post.find(:first, :by => :title)
    assert_equal posts(:welcome), Post.find(:first, :by => :title, :order => :desc)
  end

  def test_find_last_with_order
    assert_equal posts(:welcome), Post.find(:last, :by => :id, :order => :desc)
    assert_equal posts(:welcome), Post.find(:last, :by => :title)
    assert_equal posts(:post1),   Post.find(:last, :by => :title, :order => :desc)
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
    assert_equal post.id, back.id
  end

  def test_find_all_by_attr_name
    assert_equal [ posts(:welcome) ], Post.find_all_by_approved(true)
    assert_equal [ posts(:post1) ],   Post.find_all_by_approved(false)
  end
end
