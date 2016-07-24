class Classification < ActiveRecord::Base
  validates :name, presence: true
end
