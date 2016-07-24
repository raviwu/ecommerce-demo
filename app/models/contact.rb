class Contact < ActiveRecord::Base
  belongs_to :user

  validates :attn_name, presence: true
  validates :user, presence: true
end
