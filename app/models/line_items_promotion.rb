class LineItemsPromotion < ActiveRecord::Base
  belongs_to :line_item
  belongs_to :promotion

  validates :line_item, presence: true
  validates :promotion, presence: true
  validates :discount_amount, presence: true
end
