class InventoryUnit < ActiveRecord::Base
  belongs_to :variant
  belongs_to :line_item, optional: true

  validates :status, presence: true
  validates :variant, presence: true
end
