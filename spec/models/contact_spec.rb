require "rails_helper"

RSpec.describe Contact, type: :model do
  subject { create(:contact) }

  it { should belong_to(:user) }
  it { should validate_presence_of(:attn_name) }
  it { should validate_presence_of(:user) }
end
