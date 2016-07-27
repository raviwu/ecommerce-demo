require "rails_helper"

RSpec.describe OrdersPromotion, type: :model do
  it { should belong_to(:order) }
  it { should belong_to(:promotion) }
  it { should validate_presence_of(:order) }
  it { should validate_presence_of(:promotion) }
end
