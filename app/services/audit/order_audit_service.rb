module Audit
  class OrderAuditService
    def self.call(order)
      new(order).call
    end

    def initialize(order)
      @order = order
    end

    def call
      payload = build_payload
      MongoDatabase.audit_collection.insert_one(payload)
      payload
    rescue => e
      Rails.logger.error("[AuditLog] Error recording MongoDB audit event for Order #{@order&.id}: #{e.class} - #{e.message}")
      nil
    end

    private

    def build_payload
      # Infer restaurant_id from the first order item product if present
      first_item = @order.order_items.first
      restaurant_id = first_item&.product&.restaurant_id&.to_s

      {
        event: "ORDER_CREATED",
        order_id: @order.id.to_s,
        customer_id: @order.customer_id.to_s,
        restaurant_id: restaurant_id,
        total: @order.total.to_f,
        items_count: @order.order_items.sum(&:quantity),
        created_at: Time.current.utc
      }
    end
  end
end
