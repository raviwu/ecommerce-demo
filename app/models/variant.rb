class Variant < ActiveRecord::Base
  belongs_to :currency
  belongs_to :product

  store :properties, coder: JSON

  validates :price, presence: true
  validates :currency, presence: true
  validates :product, presence: true
end
