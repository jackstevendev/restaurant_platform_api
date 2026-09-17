class InventoryMailer < ApplicationMailer
  default from: ENV.fetch("MAILER_SENDER", "notifications@restaurantplatform.com")

  def low_stock_alert(restaurant, low_stock_items)
    @restaurant = restaurant
    @low_stock_items = low_stock_items

    mail(
      to: restaurant.email,
      subject: "⚠️ Low Stock Alert — #{restaurant.name}"
    )
  end
end
