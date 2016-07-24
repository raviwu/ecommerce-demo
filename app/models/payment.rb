class Payment < ActiveRecord::Base
  belongs_to :user
  belongs_to :currency
  belongs_to :order

  validates :user, presence: true
  validates :currency, presence: true
  validates :order, presence: true
  validates :payment_number, presence: true, uniqueness: true
  validates :status, presence: true
  validates :payment_method, presence: true
end
