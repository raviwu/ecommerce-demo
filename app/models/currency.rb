class Currency < ActiveRecord::Base
  has_many :variants

  validates :name, presence: true
  validates :symbol, presence: true
end
