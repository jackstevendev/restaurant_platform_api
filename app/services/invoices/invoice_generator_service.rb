module Invoices
  class InvoiceGeneratorService
    def self.call(order)
      new(order).call
    end

    def initialize(order)
      @order = order
    end

    def call
      invoice_number = "INV-#{@order.id.to_s[0..7].upcase}-#{Time.current.strftime('%Y%m%d')}"
      
      items = @order.order_items.map do |item|
        {
          product_name: item.product&.name || "Item",
          quantity: item.quantity,
          unit_price: item.price.to_f,
          subtotal: (item.price * item.quantity).to_f
        }
      end

      subtotal = items.sum { |i| i[:subtotal] }
      tax = (subtotal * 0.10).round(2)
      total = (subtotal + tax).round(2)

      {
        invoice_number: invoice_number,
        order_id: @order.id,
        customer_name: @order.customer&.name,
        customer_email: @order.customer&.email,
        issued_at: Time.current.utc.iso8601,
        items: items,
        subtotal: subtotal,
        tax: tax,
        total: total,
        pdf_content: generate_pdf_payload(invoice_number, items, total)
      }
    end

    private

    def generate_pdf_payload(invoice_number, items, total)
      # Simulates binary PDF invoice representation
      "PDF-1.7 [INVOICE: #{invoice_number} | CUSTOMER: #{@order.customer&.email} | TOTAL: $#{total} | ITEMS: #{items.count}]"
    end
  end
end
