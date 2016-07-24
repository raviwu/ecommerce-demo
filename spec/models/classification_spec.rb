require "rails_helper"

RSpec.describe Classification, type: :model do
  subject { create(:classification) }

  it { should have_many(:products) }
  it { should validate_presence_of(:name) }
end
