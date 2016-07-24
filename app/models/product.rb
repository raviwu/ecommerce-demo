class Product < ActiveRecord::Base
  belongs_to :classification
  has_many :variants, dependent: :destroy

  store :properties, coder: JSON

  validates :name, presence: true
  validates :available_on, presence: true
  validates :classification, presence: true
end
