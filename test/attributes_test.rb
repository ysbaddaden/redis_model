require_relative './test_helper'

class AttributesTest < Test::Unit::TestCase
  def test_attribute_names
    assert_equal [ :title, :body, :created_at, :updated_at, ], Post.attribute_names
  end

  def test_generated_attribute_methods
    [ Post, Row, Comment ].each do |model|
      obj = model.new
      
      model.attribute_names.each do |attr_name|
        assert_respond_to obj, attr_name
        assert_respond_to obj, attr_name.to_s + "="
        assert_respond_to obj, attr_name.to_s + "_will_change!"
      end
    end
  end

  def test_string_type
    assert_nil Post.new.title
    assert_kind_of String, Post.new(:title => "Getting Started").title
  end

  def test_integer_type
    assert_nil Row.new.position
    assert_kind_of Integer, Row.new(:position => 123).position
    assert_kind_of Integer, Row.new(:position => "123").position
    assert_equal 123, Row.new(:position => "123").position
  end

  def test_date_type
    assert_nil Row.new.created_on
    assert_kind_of Date, Row.new(:created_on => Date.new(2012, 10, 24)).created_on
    assert_kind_of Date, Row.new(:created_on => "2012-10-24").created_on
    assert_equal Date.new(2012, 10, 24), Row.new(:created_on => "2012-10-24").created_on
  end

  def test_time_type
    assert_nil Post.new.created_at
    assert_kind_of Time, Post.new(:created_at => Time.new(2012, 10, 24, 12, 9, 1)).created_at
    assert_kind_of Time, Post.new(:created_at => "2012-10-24").created_at
    assert_equal Time.new(2012, 10, 24, 12, 9, 1), Post.new(:created_at => "2012-10-24 12:09:01").created_at
  end
end
