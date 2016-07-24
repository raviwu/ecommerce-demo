class Shipment < ActiveRecord::Base
  belongs_to :user
  belongs_to :handle_staff, class_name: "User", foreign_key: "handle_staff_id"

  has_many :orders

  validates :user, presence: true
  validates :handle_staff, presence: true
  validates :logistics_number, presence: true
  validates :shipment_method, presence: true
  validates :status, presence: true
end
