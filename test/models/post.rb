class Post < RedisModel::Base
  attribute :title
  attribute :body
  attribute :approved, :boolean
  timestamps
#  has_many :comments
end
