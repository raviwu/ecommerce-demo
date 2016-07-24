require "rails_helper"

RSpec.describe User, type: :model do
  subject { create(:customer) }

  it { should belong_to(:role) }
  it { should have_many(:contacts).dependent(:destroy) }
  it { should have_many(:shipments).dependent(:destroy) }
  it { should have_many(:orders).dependent(:destroy) }
  it { should have_many(:payments).dependent(:destroy) }
  it { should validate_presence_of(:email) }
  it { should validate_uniqueness_of(:email).case_insensitive }
  it { should validate_presence_of(:role) }
end
