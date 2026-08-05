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
          inventory = InventoryItem.find_by(product_id: item[:product_id])
          inventory.with_lock do
            inventory.update!(quantity: inventory.quantity - item[:quantity])
          end
        end
      end
    end
  end
end
