class Product < RedisModel::Base
  attribute :name
  attribute :currency,     :string,  :index => true
  attribute :price,        :float,   :index => true
  attribute :tva,          :float
  attribute :orders_count, :integer, :index => true
end
