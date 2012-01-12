require_relative './test_helper'

class SerializersTest < Test::Unit::TestCase
  def test_to_hash_with_empty_model
    assert_equal({
      :title => nil,
      :body => nil,
      :approved => nil,
      :created_at => nil,
      :updated_at => nil
    }, Post.new.serializable_hash)
    
    assert_equal({
      :name => nil,
      :position => nil,
      :price => nil,
      :created_on => nil,
      :updated_on => nil
    }, Row.new.serializable_hash)
  end

  def test_to_hash
    assert_equal({
      :title => "getting started",
      :body => nil,
      :approved => nil,
      :created_at => nil,
      :updated_at => nil
    }, Post.new(:title => "getting started").serializable_hash)
    
    assert_equal({
      :name => "cellphone",
      :price => 2.0,
      :position => nil,
      :created_on => nil,
      :updated_on => nil
    }, Row.new(:price => "2.0", :name => "cellphone").serializable_hash)
  end

  def test_as_json
    assert_equal({
      :title => nil,
      :body => nil,
      :approved => nil,
      :created_at => nil,
      :updated_at => nil
    }, Post.new.as_json)
    
    assert_equal({
      :name => nil,
      :position => nil,
      :price => nil,
      :created_on => nil,
      :updated_on => nil
    }, Row.new.as_json)
  end

  def test_to_json
    assert_kind_of String, Row.new.to_json
  end
end
