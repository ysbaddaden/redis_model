require_relative './test_helper'

class AttributesTest < Test::Unit::TestCase
  def test_attribute_names
    assert_equal [ :id, :title, :body, :approved, :created_at, :updated_at ], Post.attribute_names
    assert_equal [ :id, :position, :name, :price, :created_on, :updated_on ], Row.attribute_names
  end

  def test_attribute_exists?
    assert Post.attribute_exists?(:title),      "there should be a title attribute"
    assert !Post.attribute_exists?(:unknown),   "there shouldn't be an unknown attribute"
    assert Post.attribute_exists?(:created_at), "there should be a created_at attribute"
    assert Post.attribute_exists?(:updated_at), "there should be a updated_at attribute"
    assert Row.attribute_exists?(:created_on),  "there should be a created_on attribute"
    assert Row.attribute_exists?(:updated_on),  "there should be a updated_on attribute"
  end

  def test_attributes
    post = Post.new(:title => "tv-series")
    assert_kind_of Hash, post.attributes
    assert_equal "tv-series", post.attributes[:title]
    assert_same post.attributes, post.attributes
  end

  def test_generated_attribute_methods
    [ Post, Row, Comment ].each do |model|
      obj = model.new
      model.attribute_names.each do |attr_name|
        assert_respond_to attr_name, obj
        assert_respond_to attr_name.to_s + "=", obj
        assert_respond_to attr_name.to_s + "_will_change!", obj
      end
    end
  end

  def test_nil_string_type
    assert_nil Post.new.title
    refute Post.new.title?
  end

  def test_string_type
    post = Post.new(:title => "Getting Started")
    assert_kind_of String, post.title
    assert post.title?
  end

  def test_nil_integer_type
    assert_nil Row.new.position
    refute Row.new.position?
  end

  def test_empty_string_integer_type
    assert_nil Row.new(:position => "").position
    refute Row.new.position?
  end

  def test_blank_string_integer_type
    assert_nil Row.new(:position => " \t ").position
    refute Row.new.position?
  end

  def test_integer_type
    assert_kind_of Integer, Row.new(:position => 123).position
    assert_kind_of Integer, Row.new(:position => "123").position
    assert_equal 123, Row.new(:position => "123").position
    assert Row.new(:position => "123").position?
  end

  def test_empty_string_float_type
    assert_nil Row.new(:price => "").price
    refute Row.new.price?
  end

  def test_blank_string_float_type
    assert_nil Row.new(:price => "  \t ").price
    refute Row.new.price?
  end

  def test_float_type
    assert_kind_of Float, Row.new(:price => 12.67).price
    assert_kind_of Float, Row.new(:price => 12.67).price
    assert_equal 12.0, Row.new(:price => "12").price
    assert Row.new(:price => "12.67").price?
  end

  def test_boolean_type
    assert Post.new(:approved => true).approved?
    assert Post.new(:approved => "on").approved?,    "on is true"
    assert Post.new(:approved => 1).approved?,       "'1' is true"
    assert Post.new(:approved => "1").approved?,     "'1' is true"
    refute Post.new(:approved => false).approved?
    refute Post.new(:approved => nil).approved?,     "nil is false"
    refute Post.new(:approved => "").approved?,      "empty string is false"
    refute Post.new(:approved => "  \t ").approved?, "blank string is false"
    refute Post.new(:approved => 0).approved?,       "0 is false"
    refute Post.new(:approved => "0").approved?,     "'0' is false"
    refute Post.new(:approved => "off").approved?,   "off is false"
  end

  def test_nil_date_type
    assert_nil Row.new.created_on
    refute Row.new.created_on?
  end

  def test_date_type
    assert_kind_of Date, Row.new(:created_on => Date.new(2012, 10, 24)).created_on
    assert_kind_of Date, Row.new(:created_on => "2012-10-24").created_on
    assert_equal Date.new(2012, 10, 24), Row.new(:created_on => "2012-10-24").created_on
  end

  def test_nil_time_type
    assert_nil Post.new.created_at
    refute Post.new.created_at?
  end

  def test_time_type
    assert_kind_of Time, Post.new(:created_at => Time.new(2012, 10, 24, 12, 9, 1)).created_at
    assert_kind_of Time, Post.new(:created_at => "2012-10-24").created_at
    assert_equal Time.new(2012, 10, 24, 12, 9, 1), Post.new(:created_at => "2012-10-24 12:09:01").created_at
  end
end
