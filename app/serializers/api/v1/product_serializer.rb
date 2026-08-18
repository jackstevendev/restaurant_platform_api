module Api
  module V1
    class ProductSerializer
    include JSONAPI::Serializer

    attributes :name,
              :active,
              :price
    end
  end
end
