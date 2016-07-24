class Order < ActiveRecord::Base
  belongs_to :user
  belongs_to :currency
  belongs_to :shipment

  store :billing_contact_info, asseccors: [:attn_name, :email, :phone, :address, :zipcode], coder: JSON
  store :shipping_contact_info, asseccors: [:attn_name, :email, :phone, :address, :zipcode], coder: JSON

  validates :order_number, presence: true, uniqueness: true
  validates :user, presence: true
  validates :billing_contact_info, presence: true
  validates :shipping_contact_info, presence: true
  validates :currency, presence: true
  validates :line_item_total, presence: true
  validates :promo_total, presence: true
  validates :status, presence: true
end
