require_relative './test_helper'

class PersistanceTest < Test::Unit::TestCase
  def test_create
    post = Post.new
    post.create
    assert_not_nil post.id
    assert_kind_of Integer, post.id
    assert_kind_of Time, post.created_at
    assert_kind_of Time, post.updated_at
    
    row = Row.new
    row.create
    assert_not_nil row.id
    assert_kind_of Date, row.created_on
    assert_kind_of Date, row.updated_on
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

#  def test_class_create
#  end

#  def test_class_update
#  end

#  def test_class_destroy
#  end

#  def test_class_delete
#  end
end
