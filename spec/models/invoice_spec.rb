require "rails_helper"

RSpec.describe Invoice, type: :model do
  subject { create(:invoice, invoice_number: "test_invoice_number") }

  it { should belong_to(:payment) }
  it { should validate_presence_of(:payment) }
  it { should validate_presence_of(:invoice_number) }
  it { should validate_uniqueness_of(:invoice_number) }
end
