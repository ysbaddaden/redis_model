class Post < RedisModel::Base
  attribute :title
  attribute :body
  attribute :approved, :boolean, :index => true
  timestamps

  has_many :comments
end
