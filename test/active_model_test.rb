require_relative './test_helper'
require 'active_support/test_case'
require 'active_model/test_case'
require 'active_model/lint'

class LintTest < ActiveModel::TestCase
  include ActiveModel::Lint::Tests

  def setup
    @model = Post.new
  end
end
