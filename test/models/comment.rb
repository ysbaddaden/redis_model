class Comment < RedisModel::Base
#  belongs_to :post
  attribute :body
  attribute :user_name
  attribute :user_email
  attribute :created_at, :time
end
