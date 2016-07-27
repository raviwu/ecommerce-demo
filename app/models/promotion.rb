class Promotion < ActiveRecord::Base
  scope :active_order_promotions, -> { where(
      'start_at <= ? AND expire_at >= ? AND scope = ?', Time.current, Time.current, Order.to_s
    ) }
  scope :active_product_promotions, -> { where(
      'start_at <= ? AND expire_at >= ? AND scope = ?', Time.current, Time.current, Product.to_s
    ) }
  scope :active_line_item_promotions, -> { where(
      'start_at <= ? AND expire_at >= ? AND scope = ?', Time.current, Time.current, LineItem.to_s
    ) }

  has_many :orders_promotions, dependent: :destroy
  has_many :orders, through: :orders_promotions

  has_many :line_items_promotions, dependent: :destroy
  has_many :line_items, through: :line_items_promotions

  store :rule, coder: JSON

  validates :scope, presence: true
  validates :description, presence: true
  validates :rule, presence: true
  validates :start_at, presence: true
  validates :expire_at, presence: true
  validates :active, inclusion: { in: [true, false] }
  validates :active, exclusion: { in: [nil] }

  # The PROMO_RULE_FORMAT is checker and helper when creating new Promotion from controller
  # Promo total Calculation are based on the rule infomation defined in this column
  # optional included_variant_ids => will ignore those variant lineitems outside the list
  # optional excluded_variant_ids => will ingore those variant lineitems inside the list
  PROMO_RULE_FORMAT = {
    discount_on_total_when_total_meets_requirement:
      {
        type: :discount_on_total_when_total_meets_requirement,
        require_total: "Integer",
        discount_rate: "Float",
        included_variant_ids: "Array",
        excluded_variant_ids: "Array",
        included_product_ids: "Array",
        excluded_product_ids: "Array",
        discount_on_remainer: "Boolean",
      },
    discount_on_total_when_quantity_meets_requirement:
      {
        type: :discount_on_total_when_quantity_meets_requirement,
        require_quantity: "Integer",
        discount_rate: "Float",
        included_variant_ids: "Array",
        excluded_variant_ids: "Array",
        included_product_ids: "Array",
        excluded_product_ids: "Array",
        discount_on_remainer: "Boolean",
      }
  }

  def is_variant_promotable?(variant)
    return false if rule[:excluded_variant_ids].present? && rule[:excluded_variant_ids].include?(variant.id)
    (rule[:included_variant_ids].present? && rule[:included_variant_ids].include?(variant.id)) || \
      (rule[:included_variant_ids].blank? && rule[:excluded_variant_ids].blank?)
  end

  def is_line_item_promotable?(line_item)
    return false unless is_variant_promotable?(line_item.variant)
    (is_discount_by_total? && line_item.calculate_line_item_total >= rule[:require_total]) || (is_discount_by_quantity? && line_item.quantity >= rule[:require_quantity])
  end

  def is_discount_by_total?
    rule[:require_total].present?
  end

  def is_discount_by_quantity?
    rule[:require_quantity].present?
  end

  def calculate_line_item_promo_total_of(line_item, options = {})
    return nil unless is_line_item_promotable?(line_item)

    total_count_base = line_item.calculate_line_item_total

    if rule[:discount_on_remainer]
      total_count_base - (total_count_base * rule[:discount_rate])
    elsif is_discount_by_total? && !rule[:discount_on_remainer]
      deduct_count = total_count_base / rule[:require_total]
      deduct_count * rule[:require_total] * (1 - rule[:discount_rate])
    elsif is_discount_by_quantity? && !rule[:discount_on_remainer]
      deduct_count = line_item.quantity / rule[:require_quantity]
      deduct_count * rule[:require_quantity] * line_item.unit_price * (1 - rule[:discount_rate])
    end
  end

  def self.assign_promotion_to_line_item(line_item)
    promotion_applied_result =
      active_line_item_promotions.map do |promotion|
        discount_amount = promotion.calculate_line_item_promo_total_of(line_item).ceil
        next unless discount_amount.present?
        [promotion.id, discount_amount]
      end
    # Assign only one promotion to LineItem with highest discount_amount
    promotion_applied_result.max_by(&:last)
  end
end
