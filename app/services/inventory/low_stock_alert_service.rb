module Inventory
  class LowStockAlertService
    def self.call
      new.call
    end

    def call
      restaurants_with_low_stock.each do |restaurant, items|
        if restaurant.email.blank?
          truncated_name = restaurant.name.truncate(50)
          Rails.logger.warn("[LowStockAlertService] Restaurant #{restaurant.id} (#{truncated_name}) has no email configured. Skipping alert.")
          next
        end

        InventoryMailer.low_stock_alert(restaurant, items).deliver_now
      rescue StandardError => e
        Rails.logger.error("[LowStockAlertService] Failed to send alert for Restaurant #{restaurant.id}: #{e.class} - #{e.message}")
      end
    end

    private

    def restaurants_with_low_stock
      # NOTE: group_by loads all low-stock items into memory.
      # Acceptable for current scale (~hundreds of products).
      # Consider batch processing if catalog grows beyond ~10K products.
      InventoryItem
        .below_minimum_stock
        .includes(product: :restaurant)
        .group_by { |item| item.product.restaurant }
    end
  end
end
