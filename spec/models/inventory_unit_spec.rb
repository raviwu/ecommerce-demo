require "rails_helper"

RSpec.describe InventoryUnit, type: :model do
  subject { create(:inventory_unit) }

  it { should belong_to(:variant) }
  it { should belong_to(:line_item) }
  it { should validate_presence_of(:variant) }
  it { should validate_presence_of(:status) }
end
