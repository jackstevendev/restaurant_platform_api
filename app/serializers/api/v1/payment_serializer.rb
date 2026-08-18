module Api
  module V1
    class PaymentSerializer
    include JSONAPI::Serializer

    attributes :provider,
              :amount,
              :status,
              :transaction_id
    end
  end
end
