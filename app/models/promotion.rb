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

  def is_order_promotable?(order, order_total, order_quantity)
    (is_discount_by_total? && order_total >= rule[:require_total]) || (is_discount_by_quantity? && order_quantity >= rule[:require_quantity])
  end

  def get_promotable_order_total_and_quantity(order)
    if rule[:included_product_ids].present?
      products = Product.where('id IN (?)', rule[:included_product_ids])
      order_total = order.line_items.where('variant_id IN (?)', products.map(&:variants).flatten.map(&:id))&.map(&:line_item_total).inject(:+)
      order_quantity = order.line_items.where('variant_id IN (?)', products.map(&:variants).flatten.map(&:id))&.map(&:quantity).inject(:+)
    elsif rule[:excluded_product_ids].present?
      excluded_products = Product.where('id IN (?)', rule[:excluded_product_ids])
      order_total = order.line_items.where('variant_id NOT IN (?)', excluded_products.map(&:variants).flatten.map(&:id))&.map(&:line_item_total).inject(:+)
      order_quantity = order.line_items.where('variant_id NOT IN (?)', excluded_products.map(&:variants).flatten.map(&:id))&.map(&:quantity).inject(:+)
    elsif rule[:included_product_ids].blank? && rule[:excluded_product_ids].blank?
      order_total = order.line_items&.map(&:line_item_total).inject(:+)
      order_quantity = order.line_items&.map(&:quantity).inject(:+)
    end

    order_total ||= 0
    order_quantity ||= 0
    [order_total, order_quantity]
  end

  def is_product_promotable?(product)
    return false if rule[:excluded_product_ids].present? && rule[:excluded_product_ids].include?(product.id)
    (rule[:included_product_ids].present? && rule[:included_product_ids].include?(product.id)) || \
      (rule[:included_product_ids].blank? && rule[:excluded_product_ids].blank?)
  end

  def is_product_meets_promo_requirement?(product, total, quantity)
    return false unless is_product_promotable?(product)
    (is_discount_by_total? && total >= rule[:require_total]) || (is_discount_by_quantity? && quantity >= rule[:require_quantity])
  end

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

  def calculate_line_item_discount_amount(line_item, options = {})
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
        discount_amount = promotion.calculate_line_item_discount_amount(line_item).ceil
        next unless discount_amount.present?
        [promotion.id, discount_amount]
      end
    # Assign only one promotion to LineItem with highest discount_amount
    promotion_applied_result.max_by(&:last)
  end

  def calculate_product_discount_amount(product, total, quantity, lowest_unit_price)
    return nil unless is_product_meets_promo_requirement?(product, total, quantity)

    if rule[:discount_on_remainer]
      total - (total * rule[:discount_rate])
    elsif is_discount_by_total? && !rule[:discount_on_remainer]
      deduct_count = total / rule[:require_total]
      deduct_count * rule[:require_total] * (1 - rule[:discount_rate])
    elsif is_discount_by_quantity? && !rule[:discount_on_remainer]
      deduct_count = quantity / rule[:require_quantity]
      deduct_count * rule[:require_quantity] * lowest_unit_price * (1 - rule[:discount_rate])
    end
  end

  def calculate_order_discount_amount(order)
    order_total, order_quantity = get_promotable_order_total_and_quantity(order)
    return nil unless is_order_promotable?(order, order_total, order_quantity)

    if rule[:discount_on_remainer]
      order_total - (order_total * rule[:discount_rate])
    elsif is_discount_by_total? && !rule[:discount_on_remainer]
      deduct_count = order_total / rule[:require_total]
      deduct_count * rule[:require_total] * (1 - rule[:discount_rate])
    end

    # TODO: Handle "Buy X get O free condition"
  end

  def self.assign_promotion_to_product(product, total, quantity, lowest_unit_price)
    promotion_applied_result =
      active_product_promotions.map do |promotion|
        discount_amount = promotion.calculate_product_discount_amount(product, total, quantity, lowest_unit_price)&.ceil
        next unless discount_amount.present?
        [promotion.id, product.id, discount_amount]
      end
    # Assign only one promotion to Product with highest discount_amount
    promotion_applied_result.compact.max_by(&:last)
  end

  def self.assign_product_promotion_to_order(order)
    return unless Promotion.active_product_promotions.present?

    products = order.line_items.map(&:variant).map(&:product).uniq

    products.map do |product|
      line_items = order.line_items.where('variant_id IN (?)', product.variants.ids)
      total = line_items.map(&:line_item_total).compact.inject(&:+)
      quantity = line_items.map(&:quantity).compact.inject(&:+)
      lowest_unit_price = line_items.min_by(&:unit_price).unit_price

      assign_promotion_to_product(product, total, quantity, lowest_unit_price)
    end.compact
  end

  def self.assign_order_promotion_to_order(order)
    return unless Promotion.active_order_promotions.present?
    promotion_applied_result =
      active_order_promotions.map do |promotion|
        discount_amount = promotion.calculate_order_discount_amount(order)&.ceil
        next unless discount_amount.present?
        [promotion.id, promotion.rule[:included_product_ids], promotion.rule[:excluded_product_ids], discount_amount]
      end
    # Assign only one promotion to Order with highest discount_amount
    promotion_applied_result.compact.max_by(&:last)
  end
end
