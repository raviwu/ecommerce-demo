class User < ActiveRecord::Base
  belongs_to :role
  has_secure_password

  has_many :contacts, dependent: :destroy

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :role, presence: true
end
