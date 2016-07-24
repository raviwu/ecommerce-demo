require "rails_helper"

RSpec.describe Role, type: :model do
  subject { create(:admin_role) }

  it { should have_many(:users) }
end
