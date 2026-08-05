module Api
  module V1
    class PricingService
      def self.calculate_total(order_items)
        new(order_items).calculate_total
      end

      def initialize(order_items)
        @order_items = order_items
      end

      def calculate_total
        @order_items.sum { |item| item.price * item.quantity }
      end
    end
  end
end
