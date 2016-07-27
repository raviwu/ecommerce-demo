class OrdersPromotion < ActiveRecord::Base
  belongs_to :order
  belongs_to :promotion

  validates :order, presence: true
  validates :promotion, presence: true
  validates :discount_amount, presence: true
end
