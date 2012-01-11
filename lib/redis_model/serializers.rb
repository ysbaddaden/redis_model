module RedisModel
  module Serializers
    def to_hash
      @attributes.dup
    end

    def to_json
      to_hash.to_json
    end
  end
end
