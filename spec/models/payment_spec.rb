require "rails_helper"

RSpec.describe Payment, type: :model do
  subject { create(:payment, payment_number: "test_payment_number") }

  it { should belong_to(:user) }
  it { should belong_to(:currency) }
  it { should belong_to(:order) }
  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:currency) }
  it { should validate_presence_of(:order) }
  it { should validate_presence_of(:payment_number) }
  it { should validate_uniqueness_of(:payment_number) }
  it { should validate_presence_of(:status) }
  it { should validate_presence_of(:payment_method) }
end
