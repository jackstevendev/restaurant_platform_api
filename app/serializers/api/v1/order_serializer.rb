module Api
  module V1
    class OrderSerializer
      include JSONAPI::Serializer

      attributes :public_id,
                :status,
                :total,
                :created_at,
                :updated_at

      belongs_to :customer
      has_one :payment
      has_many :order_items
    end
  end
end
