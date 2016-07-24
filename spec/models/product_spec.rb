require "rails_helper"

RSpec.describe Product do
  subject { create(:product) }

  it { should belong_to(:classification) }
  it { should have_many(:variants).dependent(:destroy) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:available_on) }
  it { should validate_presence_of(:classification) }
end
