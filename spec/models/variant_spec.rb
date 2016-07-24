require "rails_helper"

RSpec.describe Variant, type: :model do
  subject { create(:variant) }

  it { should belong_to(:currency) }
  it { should belong_to(:product) }
  it { should validate_presence_of(:price) }
  it { should validate_presence_of(:currency) }
  it { should validate_presence_of(:product) }
end
