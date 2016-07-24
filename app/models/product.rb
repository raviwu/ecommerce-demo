class Product < ActiveRecord::Base
  belongs_to :classification

  store :properties, coder: JSON

  validates :name, presence: true
  validates :available_on, presence: true
  validates :classification, presence: true
end
