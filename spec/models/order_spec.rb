require "rails_helper"

RSpec.describe Order, type: :model do
  subject { create(:order, order_number: "test_order_number") }

  it { should belong_to(:user) }
  it { should belong_to(:currency) }
  it { should belong_to(:shipment) }
  it { should validate_presence_of(:order_number) }
  it { should validate_uniqueness_of(:order_number) }
  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:billing_contact_info) }
  it { should validate_presence_of(:shipping_contact_info) }
  it { should validate_presence_of(:currency) }
  it { should validate_presence_of(:line_item_total) }
  it { should validate_presence_of(:promo_total) }
  it { should validate_presence_of(:status) }
end
