module Api
  module V1
    class OrderItemSerializer
      include JSONAPI::Serializer

      attributes :quantity,
                :price

      belongs_to :product

      attribute :subtotal do |item|
        item.price * item.quantity
      end
    end
  end
end
