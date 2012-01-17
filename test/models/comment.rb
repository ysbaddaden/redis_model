class Comment < RedisModel::Base
  attribute :body
  attribute :user_name
  attribute :user_email
  attribute :created_at, :time

  belongs_to :post
end
