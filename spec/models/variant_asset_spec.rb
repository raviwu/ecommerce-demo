require "rails_helper"

RSpec.describe VariantAsset, type: :model do
  subject { create(:variant_asset) }

  it { should belong_to(:variant) }
  it { should have_attached_file(:attachment) }
  it { should validate_attachment_presence(:attachment) }
  it { should validate_attachment_content_type(:attachment).
                allowing('image/png', 'image/gif').
                rejecting('text/plain', 'text/xml') }
  it { should validate_attachment_size(:attachment).
                less_than(2.megabytes) }
end
