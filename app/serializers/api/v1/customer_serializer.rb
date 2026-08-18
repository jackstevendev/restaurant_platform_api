module Api
  module V1
    class CustomerSerializer
      include JSONAPI::Serializer

      attributes :name,
                :email,
                :phone
    end
  end
end
