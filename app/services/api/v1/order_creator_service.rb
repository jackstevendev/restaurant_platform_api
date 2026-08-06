module Api
  module V1
    class OrderCreatorService
      def self.call(restaurant, order_params, products)
        new(restaurant, order_params, products).call
      end

      def initialize(restaurant, order_params, products)
        @restaurant = restaurant
        @products = products
        @customer_id = order_params[:customer_id]
        @items = order_params[:order_items]
      end

      def call
        @order = Order.new(customer_id: @customer_id)
        add_order_items
        @order.total = PricingService.calculate_total(@order.order_items)
        @order.save!
        @order
      end

      def add_order_items
        @order.order_items = @items.map do |item_params|
          product = @products[item_params[:product_id]]
          OrderItem.new(product: product, quantity: item_params[:quantity], price: product.price)
        end
      end
    end
  end
end
