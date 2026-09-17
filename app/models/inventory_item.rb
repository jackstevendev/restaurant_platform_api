class InventoryItem < ApplicationRecord
  belongs_to :product

  validates :quantity, numericality: { greater_than_or_equal_to: 0 }
  validates :minimum_stock, numericality: { greater_than_or_equal_to: 0 }

  scope :below_minimum_stock, -> { where("quantity <= minimum_stock") }
end
