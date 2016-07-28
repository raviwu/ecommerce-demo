require "rails_helper"

RSpec.describe LineItem, type: :model do
  subject do
    variant = create(:variant)
    Settings.inventory.buffer_unit.times do
      create(:inventory_unit, variant: variant, status: Settings.inventory.status.free)
    end
    create(:inventory_unit, variant: variant, status: Settings.inventory.status.free)
    create(:line_item, variant: variant)
  end

  it { should belong_to(:order) }
  it { should belong_to(:variant) }
  it { should belong_to(:currency) }
  it { should have_many(:inventory_units) }
  it { should have_many(:line_items_promotions).dependent(:destroy) }
  it { should have_many(:promotions) }
  it { should validate_presence_of(:order) }
  it { should validate_presence_of(:variant) }
  it { should validate_presence_of(:currency) }
  it { should validate_presence_of(:unit_price) }
  it { should validate_presence_of(:quantity) }
  it { should validate_exclusion_of(:lock_inventory).in_array([nil])}

  describe "calculate_line_item_total before_save" do
    let!(:variant) { create(:variant) }
    let!(:inventory) { create(:inventory_unit, variant: variant, status: Settings.inventory.status.free) }
    let!(:line_item) { build(:line_item, variant: variant, unit_price: 0, quantity: 0) }

    before(:each) do
      Settings.inventory.buffer_unit.times do
        create(:inventory_unit, variant: variant, status: Settings.inventory.status.free)
      end
    end

    it "updates the line_item_total" do
      line_item.unit_price = 100
      line_item.quantity = 1
      line_item.save
      expect(line_item.reload.line_item_total).to eq(100)
    end
  end

  describe "lock_inventory" do
    let!(:variant) { create(:variant) }
    let!(:inventory) { create(:inventory_unit, variant: variant, status: Settings.inventory.status.free) }

    before(:each) do
      Settings.inventory.buffer_unit.times do
        create(:inventory_unit, variant: variant, status: Settings.inventory.status.free)
      end
    end

    context "validates quantity with inventory unit" do
      it "is valid if quantity is less than or equal to variant stock" do
        line_item = build(:line_item, variant: variant, quantity: 1, lock_inventory: true, unit_price: 10)
        expect(line_item.valid?).to eq(true)
      end

      it "is invalid if quantity is more than variant stock" do
        line_item = build(:line_item, variant: variant, quantity: 2, lock_inventory: true, unit_price: 10)
        expect(line_item.valid?).to eq(false)
      end
    end

    context "reserve inventory before save" do
      it "reserve the inventory units" do
        create(:inventory_unit, variant: variant, status: Settings.inventory.status.free)
        line_item = create(:line_item, variant: variant, quantity: 1, lock_inventory: true, unit_price: 10)
        expect(InventoryManager.check_free_unit(variant)).to eq(1)
      end

      it "release inventory units if update quantity is lesser than previous quantity" do
        create(:inventory_unit, variant: variant, status: Settings.inventory.status.free)
        create(:inventory_unit, variant: variant, status: Settings.inventory.status.free)
        line_item = create(:line_item, variant: variant, quantity: 3, lock_inventory: true, unit_price: 10)
        line_item.quantity = 2
        line_item.save!
        expect(InventoryManager.check_free_unit(variant)).to eq(1)
      end

      it "is invalid if inventory unit is not enough" do
        create(:inventory_unit, variant: variant, status: Settings.inventory.status.free)
        line_item = create(:line_item, variant: variant, quantity: 1, lock_inventory: true, unit_price: 10)
        line_item.quantity = 5
        expect(line_item.valid?).to eq(false)
        expect(line_item.save).to eq(false)
      end
    end

    context "release all lock unit before_destroy" do
      it "release all locked inventory units" do
        create(:inventory_unit, variant: variant, status: Settings.inventory.status.free)
        line_item = create(:line_item, variant: variant, quantity: 1, lock_inventory: true, unit_price: 10)
        expect(InventoryManager.check_free_unit(variant)).to eq(1)
        line_item.destroy
        expect(InventoryManager.check_free_unit(variant)).to eq(2)
      end
    end
  end

  describe "calculate_promo_total" do
    let!(:variant) { create(:variant) }
    let!(:line_item) { create(:line_item, variant: variant, unit_price: 100000, quantity: 4, lock_inventory: false) }

    it "discounts when total meets available promotions with no discount on remainer" do
      promotion = create(
        :line_item_promotion,
        description: "相同規格商品滿 3000 折 300",
        rule: {
          type: :discount_on_total_when_total_meets_requirement,
          require_total: 300000,
          discount_rate: 0.9,
          discount_on_remainer: false
        }
      )
      line_item.calculate_promo_total
      expect(line_item.promo_total).to eq(370000)
      expect(line_item.reload.promotions).to include(promotion)
      expect(line_item.line_items_promotions.last.discount_amount).to \
        eq(line_item.line_item_total - line_item.promo_total)
    end

    it "discounts when total meets available promotions with discount on total" do
      promotion = create(
        :line_item_promotion,
        description: "相同規格商品滿 888 打 85 折",
        rule: {
          type: :discount_on_total_when_total_meets_requirement,
          require_total: 88800,
          discount_rate: 0.85,
          discount_on_remainer: true
        }
      )
      line_item.calculate_promo_total
      expect(line_item.promo_total).to eq((400000 * 0.85).floor)
      expect(line_item.promotions).to include(promotion)
      expect(line_item.line_items_promotions.last.discount_amount).to \
        eq(line_item.line_item_total - line_item.promo_total)
    end

    it "discount when quantity meets available promotions" do
      promotion = create(
        :line_item_promotion,
        description: "特定規格商品每三件打 77 折",
        rule: {
          type: :discount_on_total_when_total_meets_requirement,
          require_quantity: 3,
          discount_rate: 0.77,
          included_variant_ids: [variant.id],
          discount_on_remainer: false
        }
      )
      line_item.calculate_promo_total
      expect(line_item.promo_total).to eq((300000 * 0.77).floor + 100000)
      expect(line_item.promotions).to include(promotion)
      line_item_not_in_discount_variant = create(:line_item, lock_inventory: false)
      line_item.calculate_promo_total
      expect(line_item_not_in_discount_variant.promo_total).to be_nil
      expect(line_item_not_in_discount_variant.promotions).not_to include(promotion)
      expect(line_item.line_items_promotions.last.discount_amount).to \
        eq(line_item.line_item_total - line_item.promo_total)
    end
  end
end
