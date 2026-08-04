class Customer < ApplicationRecord
  has_many :orders, dependent: :restrict_with_exception

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: true
end
