class Row < RedisModel::Base
  attribute :position,   :integer
  attribute :price,      :float
  attribute :created_on, :date
  attribute :updated_on, :date
end
