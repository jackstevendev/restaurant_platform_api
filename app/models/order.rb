class Order < ApplicationRecord
  belongs_to :customer
  has_many :order_items, dependent: :destroy
  has_one :payment, dependent: :destroy

  enum status: {
    pending: "pending",
    paid: "paid",
    cancelled: "cancelled",
    completed: "completed"
  }

  validates :total, numericality: { greater_than_or_equal_to: 0 }
end
