require "rails_helper"

RSpec.describe LineItemsPromotion, type: :model do
  it { should belong_to(:line_item) }
  it { should belong_to(:promotion) }
  it { should validate_presence_of(:line_item) }
  it { should validate_presence_of(:promotion) }
end
