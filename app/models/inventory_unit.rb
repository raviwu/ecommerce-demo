class InventoryUnit < ActiveRecord::Base
  belongs_to :variant

  validates :status, presence: true
  validates :variant, presence: true
end
