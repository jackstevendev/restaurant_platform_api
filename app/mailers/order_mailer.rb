class OrderMailer < ApplicationMailer
  default from: ENV.fetch("MAILER_SENDER", "notifications@restaurantplatform.com")

  def order_confirmation(order, invoice_url)
    @order = order
    @customer = order.customer
    @invoice_url = invoice_url

    mail(
      to: @customer.email,
      subject: "Order Confirmation ##{@order.id.to_s[0..7].upcase}"
    )
  end
end
