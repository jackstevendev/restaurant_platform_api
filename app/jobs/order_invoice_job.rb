class OrderInvoiceJob < ApplicationJob
  queue_as :invoices

  retry_on StandardError, wait: :exponentially_longer, attempts: 5
  discard_on ActiveRecord::RecordNotFound

  def perform(order_id)
    Rails.logger.info("[OrderInvoiceJob] Starting invoice and notification processing for Order #{order_id}")

    order = Order.includes(:customer, order_items: :product).find(order_id)

    # Idempotency check: avoid duplicate invoice generation & customer emails on retries
    if invoice_already_processed?(order.id)
      Rails.logger.info("[OrderInvoiceJob] Order #{order_id} already processed. Skipping to maintain idempotency.")
      return
    end

    # Step 1: Generate structured invoice data
    invoice_data = Invoices::InvoiceGeneratorService.call(order)

    # Step 2: Upload to S3 (deterministic path)
    s3_path = "invoices/#{order.id}.pdf"
    invoice_url = Storage::S3UploaderService.call(invoice_data[:pdf_content], s3_path)

    # Step 3: Send confirmation email to customer
    OrderMailer.order_confirmation(order, invoice_url).deliver_now

    # Mark as processed
    mark_invoice_as_processed(order.id)

    Rails.logger.info("[OrderInvoiceJob] Successfully generated invoice and sent confirmation for Order #{order_id}")
    invoice_url
  end

  private

  def invoice_already_processed?(order_id)
    Rails.cache.exist?("order_invoice_processed:#{order_id}")
  end

  def mark_invoice_as_processed(order_id)
    Rails.cache.write("order_invoice_processed:#{order_id}", true, expires_in: 30.days)
  end
end
