require "rails_helper"

RSpec.describe Order, type: :model do
  subject { create(:order, order_number: "test_order_number") }

  it { should belong_to(:user) }
  it { should belong_to(:currency) }
  it { should belong_to(:shipment) }
  it { should have_many(:payments).dependent(:destroy) }
  it { should have_many(:line_items).dependent(:destroy) }
  it { should have_many(:orders_promotions).dependent(:destroy) }
  it { should have_many(:promotions) }
  it { should validate_presence_of(:order_number) }
  it { should validate_uniqueness_of(:order_number) }
  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:billing_contact_info) }
  it { should validate_presence_of(:shipping_contact_info) }
  it { should validate_presence_of(:currency) }
  it { should validate_presence_of(:line_item_total) }
  it { should validate_presence_of(:promo_total) }
  it { should validate_presence_of(:status) }

  describe "calculate_promo_total" do
    let!(:product) { create(:product) }
    let!(:variant_1) { create(:variant, product: product) }
    let!(:line_item_1) { create(:line_item, variant: variant_1, unit_price: 100000, quantity: 4, lock_inventory: false) }
    let!(:variant_2) { create(:variant, product: product) }
    let!(:line_item_2) { create(:line_item, variant: variant_2, unit_price: 100000, quantity: 3, lock_inventory: false) }

    let!(:variant_3) { create(:variant) }
    let!(:line_item_3) { create(:line_item, variant: variant_3, unit_price: 10000, quantity: 3, lock_inventory: false) }

    let!(:order) { create(:order) }

    before(:each) do
      order.line_items << line_item_1
      order.line_items << line_item_2
      order.line_items << line_item_3
    end

    it "discounts when total meets available promotions with no discount on remainer" do
      product_promotion = create(
        :product_promotion,
        description: "相同商品滿 3000 折 300",
        rule: {
          type: :discount_on_total_when_total_meets_requirement,
          included_product_ids: [product.id],
          require_total: 300000,
          discount_rate: 0.9,
          discount_on_remainer: false
        }
      )
      order.calculate_promo_total
      expect(order.promo_total).to eq(670000)
      expect(order.promotions).to include(product_promotion)
      expect(order.orders_promotions.last.discount_amount).to eq(60000)
    end

    it "discounts when total meets available promotions with discount on total" do
      product_promotion = create(
        :product_promotion,
        description: "15% off for same spec product if the total more than 888",
        rule: {
          type: :discount_on_total_when_total_meets_requirement,
          excluded_product_ids: [product.id],
          require_total: 88800,
          discount_rate: 0.85,
          discount_on_remainer: true
        }
      )
      order_promotion = create(
        :order_promotion,
        description: "20% off if the order total more than 199 (Some product excluded)",
        rule: {
          type: :discount_on_total_when_total_meets_requirement,
          excluded_product_ids: [product.id],
          require_total: 19900,
          discount_rate: 0.8,
          discount_on_remainer: true
        }
      )
      order.calculate_promo_total
      expect(order.promo_total).to eq(724000)
      expect(order.promotions).to include(order_promotion)
      expect(order.promotions).not_to include(product_promotion)
      expect(order.orders_promotions.last.discount_amount).to eq(6000)
    end

    it "discount when quantity meets available promotions" do
      product_promotion = create(
        :product_promotion,
        description: "23% off for every three same spec products",
        rule: {
          type: :discount_on_total_when_total_meets_requirement,
          included_product_ids: [product.id],
          require_quantity: 3,
          discount_rate: 0.77,
          discount_on_remainer: false
        }
      )
      order.calculate_promo_total
      expect(order.promo_total).to eq((600000 * 0.77).floor + 100000 + 30000)
      expect(order.promotions).to include(product_promotion)
    end
  end
end
