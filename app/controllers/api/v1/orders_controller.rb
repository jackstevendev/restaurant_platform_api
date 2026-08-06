module Api
  module V1
    class OrdersController < ApplicationController
      def index
        @orders = Order.includes(:customer, :payment, order_items: { product: :restaurant }).all
        render json: @orders.map { |order| serialize_order(order) }, status: :ok
      end

      def show
        @order = Order.includes(:customer, :payment, order_items: { product: :restaurant }).find(params[:id])
        render json: serialize_order(@order), status: :ok
      end

      def place_order
        @order = OrderProcessorService.call(restaurant_id, order_params)
        render json: { message: "Order placed successfully", order: serialize_order(@order) }, status: :created
      end

      private

      def serialize_order(order)
        first_product = order.order_items.first&.product
        restaurant = first_product&.restaurant

        {
          id: order.id,
          public_id: order.public_id,
          status: order.status,
          total: order.total.to_f,
          created_at: order.created_at,
          updated_at: order.updated_at,
          customer: order.customer ? {
            id: order.customer.id,
            name: order.customer.name,
            email: order.customer.email,
            phone: order.customer.phone
          } : nil,
          restaurant: restaurant ? {
            id: restaurant.id,
            name: restaurant.name,
            address: restaurant.address
          } : nil,
          payment: order.payment ? {
            id: order.payment.id,
            provider: order.payment.provider,
            amount: order.payment.amount.to_f,
            status: order.payment.status,
            transaction_id: order.payment.transaction_id,
            created_at: order.payment.created_at
          } : nil,
          order_items: order.order_items.map do |item|
            {
              id: item.id,
              quantity: item.quantity,
              unit_price: item.price.to_f,
              subtotal: (item.price * item.quantity).to_f,
              product: item.product ? {
                id: item.product.id,
                name: item.product.name,
                active: item.product.active
              } : nil
            }
          end
        }
      end

      def order_params
        params.require(:order).permit(:customer_id, order_items: [ :product_id, :quantity ])
      end

      def restaurant_id
        @restaurant_id ||= params["restaurant_id"]
      end
    end
  end
end
