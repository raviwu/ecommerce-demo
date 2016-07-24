class User < ActiveRecord::Base
  belongs_to :role
  has_secure_password

  has_many :contacts, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_many :shipments, dependent: :destroy

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :role, presence: true

  def admin?
    role.name == Settings.roles.admin
  end
end
