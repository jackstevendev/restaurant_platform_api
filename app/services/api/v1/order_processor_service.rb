module Api
  module V1
    class OrderProcessorService
      def self.place_order(restaurant_id, order_params)
        new(restaurant_id, order_params).place_order
      end

      def initialize(restaurant_id, order_params)
        @restaurant_id = restaurant_id
        @order_params = order_params
      end

      def place_order
        ActiveRecord::Base.transaction do
          InventoryCheckerService.call(restaurant, @order_params[:order_items], products)
          InventoryReserverService.call(restaurant, @order_params[:order_items], products)
          OrderCreatorService.call(restaurant, @order_params, products)
        end
      end

      private

      def restaurant
        @restaurant ||= Restaurant.includes(:products).find(@restaurant_id)
      end

      def products
        @products ||= restaurant.products
      end
    end
  end
end
