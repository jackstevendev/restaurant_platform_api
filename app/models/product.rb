class Product < ApplicationRecord
  belongs_to :restaurant
  has_one :inventory_item, dependent: :destroy
  has_many :order_items, dependent: :restrict_with_exception

  validates :name, presence: true
  validates :price, numericality: { greater_than: 0 }

  scope :active, -> { where(active: true) }
end
