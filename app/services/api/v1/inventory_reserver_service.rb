module Api
  module V1
    class InventoryReserverService
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
          product = @products[item[:product_id]]
          inventory = product.inventory_item
          inventory.with_lock do
            if inventory.quantity < item[:quantity]
              raise Errors::InsufficientInventory.new("Insufficient inventory for #{product.name}")
            end
            inventory.update!(quantity: inventory.quantity - item[:quantity])
          end
        end
      end
    end
  end
end
