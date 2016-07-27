require "rails_helper"

RSpec.describe Promotion, type: :model do
  it { should have_many(:orders_promotions).dependent(:destroy) }
  it { should have_many(:orders) }
  it { should have_many(:line_items_promotions).dependent(:destroy) }
  it { should have_many(:line_items) }
  it { should validate_presence_of(:scope) }
  it { should validate_presence_of(:description) }
  it { should validate_presence_of(:rule) }
  it { should validate_presence_of(:start_at) }
  it { should validate_presence_of(:expire_at) }
  it { should validate_exclusion_of(:active).in_array([nil])}
end
