class Post < RedisModel::Base
  attribute :title
  attribute :body
  attribute :created_at, :time
  attribute :updated_at, :time

#  has_many :comments
end

