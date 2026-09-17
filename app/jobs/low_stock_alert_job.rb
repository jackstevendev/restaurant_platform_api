class LowStockAlertJob < ApplicationJob
  queue_as :default

  retry_on StandardError, wait: :exponentially_longer, attempts: 3

  def perform
    Rails.logger.info("[LowStockAlertJob] Starting daily low stock check")
    Inventory::LowStockAlertService.call
    Rails.logger.info("[LowStockAlertJob] Low stock check completed")
  end
end
