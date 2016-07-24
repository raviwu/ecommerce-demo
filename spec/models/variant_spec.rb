require "rails_helper"

RSpec.describe Variant, type: :model do
  subject { create(:variant) }

  it { should belong_to(:currency) }
  it { should belong_to(:product) }
  it { should have_many(:variant_assets).dependent(:destroy) }
  it { should validate_presence_of(:price) }
  it { should validate_presence_of(:currency) }
  it { should validate_presence_of(:product) }

  describe "validate :properties_conform_to_product" do
    let!(:product) do
      create(
        :product,
        properties: {
          color: %w(red black),
          bandwidth: %w(1G 3G 5G)
        }
      )
    end

    it "is invalid if the variant properties contains invalid values" do
      variant = build(
        :variant,
        product: product,
        properties: {
          color: "yellow",
          bandwidth: "500G"
        }
      )
      expect(variant.valid?).to eq(false)
    end

    it "is valid if the variant properties use valid values" do
      variant = build(
        :variant,
        properties: {
          color: "red",
          bandwidth: "5G"
        }
      )
      expect(variant.valid?).to eq(true)
    end
  end
end
