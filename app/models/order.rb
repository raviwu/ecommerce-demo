class Order < ActiveRecord::Base
  belongs_to :user
  belongs_to :currency
  belongs_to :shipment

  # User can have many payments for an order, keep
  # record the pass / failed attempts of payment history
  has_many :payments, dependent: :destroy

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
