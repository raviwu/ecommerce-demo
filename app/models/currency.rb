class Currency < ActiveRecord::Base
  validates :name, presence: true
  validates :symbol, presence: true
end
