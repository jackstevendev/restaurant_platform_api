module Api
  module V1
    class InventoryCheckerService
      def self.call(restaurant, items, products)
        new(restaurant, items, products).call
      end

      def initialize(restaurant, items, products)
        @restaurant = restaurant
        @items = items
        @products = products
      end

      def call
        @items.each do |item|
          product = @products.find(item[:product_id])
          if product.inventory_item.quantity < item[:quantity]
            raise Errors::InsufficientInventory.new("Insufficient inventory for #{product.name}")
          end
        end
      end
    end
  end
end
