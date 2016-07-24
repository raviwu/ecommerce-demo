require "rails_helper"

RSpec.describe Shipment, type: :model do
  subject { create(:shipment) }

  it { should belong_to(:user) }
  it { should belong_to(:handle_staff) }
  it { should have_many(:orders) }
  it { should validate_presence_of(:logistics_number) }
  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:handle_staff) }
  it { should validate_presence_of(:shipment_method) }
  it { should validate_presence_of(:status) }
end
