module Api
  module V1
    class OrderProcessorService
      def self.call(restaurant_id, order_params)
        new(restaurant_id, order_params).call
      end

      def initialize(restaurant_id, order_params)
        @restaurant_id = restaurant_id
        @order_params = order_params
      end

      def call
        ActiveRecord::Base.transaction do
          InventoryReserverService.call(restaurant, @order_params[:order_items], products)
          OrderCreatorService.call(restaurant, @order_params, products)
        end
      end

      private

      def restaurant
        @restaurant ||= Restaurant.includes(products: :inventory_item).find(@restaurant_id)
      end

      def products
        @products ||= restaurant.products.index_by(&:id)
      end
    end
  end
end
