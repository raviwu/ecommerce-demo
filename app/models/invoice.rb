class Invoice < ActiveRecord::Base
  belongs_to :payment

  validates :payment, presence: true
  validates :invoice_number, presence: true, uniqueness: true
end
