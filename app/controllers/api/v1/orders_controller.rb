
module Api
  module V1
    class OrdersController < ApplicationController
      def index
        @orders = Order.includes(:customer, :payment, order_items: { product: :restaurant }).all
        render json: @orders.map { |order| OrderSerializer.new(order).serializable_hash }, status: :ok
      end

      def show
        @order = Order.includes(:customer, :payment, order_items: { product: :restaurant }).find(params[:id])
        render json: OrderSerializer.new(order).serializable_hash
      end

      def place_order
        @order = OrderProcessorService.call(restaurant_id, order_params)
        render json: { message: "Order placed successfully", order: OrderSerializer.new(order).serializable_hash }, status: :created
      end

      private

      def order_params
        params.require(:order).permit(:customer_id, order_items: [ :product_id, :quantity ])
      end

      def restaurant_id
        @restaurant_id ||= params["restaurant_id"]
      end
    end
  end
end
