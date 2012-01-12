class Row < RedisModel::Base
  attribute  :position,   :integer
  attribute  :name
  attribute  :price,      :float
  timestamps :date
end
