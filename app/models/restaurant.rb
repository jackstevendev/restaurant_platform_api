class Restaurant < ApplicationRecord
  has_many :products, dependent: :destroy
  has_many :inventory_items, through: :products

  validates :name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
end
