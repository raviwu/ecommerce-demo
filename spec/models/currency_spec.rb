require "rails_helper"

RSpec.describe Currency, type: :model do
  subject { create(:currency) }

  it { should have_many(:variants) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:symbol) }
end
