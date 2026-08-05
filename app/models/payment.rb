class Payment < ApplicationRecord
  belongs_to :order

  enum :status, {
    pending: "pending",
    approved: "approved",
    rejected: "rejected"
  }

  validates :amount, numericality: { greater_than: 0 }
end
