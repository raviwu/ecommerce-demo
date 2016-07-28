class Order < ActiveRecord::Base
  belongs_to :user
  belongs_to :currency
  belongs_to :shipment, optional: true

  # User can have many payments for an order, keep
  # record the pass / failed attempts of payment history
  has_many :payments, dependent: :destroy
  has_many :line_items, dependent: :destroy

  has_many :orders_promotions, dependent: :destroy
  has_many :promotions, through: :orders_promotions

  store :billing_contact_info, asseccors: [:attn_name, :email, :phone, :address, :zipcode], coder: JSON
  store :shipping_contact_info, asseccors: [:attn_name, :email, :phone, :address, :zipcode], coder: JSON

  validates :order_number, presence: true, uniqueness: true
  validates :user, presence: true
  validates :billing_contact_info, presence: true
  validates :shipping_contact_info, presence: true
  validates :currency, presence: true
  validates :line_item_total, presence: true
  validates :promo_total, presence: true
  validates :status, presence: true

  def calculate_promo_total
    lock!

    product_promotions = Promotion.assign_product_promotion_to_order(self)
    order_promotion = Promotion.assign_order_promotion_to_order(self)

    # create corresponded Promotion records selectively
    if order_promotion.present?
      # If the order promotion is apply to all, then not to create
      # product promotions and lineitem promotion
      OrdersPromotion.create(order_id: id, promotion_id: order_promotion&.first, discount_amount: order_promotion&.last)

      included_product_ids, excluded_product_ids = order_promotion[1..2]

      if included_product_ids.present?
        if product_promotions.present?
          included_products = product_promotions.map do |promotion_info|
            unless included_product_ids.include?(promotion_info[1])
              OrdersPromotion.create(order_id: id, promotion_id: promotion_info&.first, discount_amount: promotion_info&.last)
              Product.find_by_id promotion_info[1]
            end
          end.compact

          excluded_line_items = line_items.where('variant_id NOT IN (?)', included_products&.map(&:variants)&.flatten&.map(&:id))

          excluded_line_items.each { |l| l.calculate_promo_total }
        else
          included_variant_ids = Product.where('id IN (?)', included_product_ids)&.map(&:variants)&.flatten&.map(&:id)

          line_items.where('variant_id NOT IN (?)', included_variant_ids).each { |l| l.calculate_promo_total }
        end
      elsif excluded_product_ids.present?
        if product_promotions.present?
          included_products = product_promotions.map do |promotion_info|
            if excluded_variant_ids.include?(promotion_info[1])
              OrdersPromotion.create(order_id: id, promotion_id: promotion_info&.first, discount_amount: promotion_info&.last)
              Product.find_by_id promotion_info[1]
            end
          end.compact

          excluded_line_items = line_items.where('variant_id NOT IN (?)', included_products&.map(&:variants)&.flatten&.map(&:id))

          excluded_line_items.each { |l| l.calculate_promo_total }
        else
          excluded_variant_ids = Product.where('id IN (?)', excluded_product_ids)&.map(&:variants)&.flatten&.map(&:id)

          line_items.where('variant_id IN (?)', excluded_variant_ids).each { |l| l.calculate_promo_total }
        end
      end
    elsif product_promotions.present?
      product_promotions.each do |promotion_info|
        OrdersPromotion.create(order_id: id, promotion_id: promotion_info&.first, discount_amount: promotion_info&.last)
      end

      included_products = product_promotions.map { |p| Product.find_by_id p[1] }

      excluded_line_items = line_items.where('variant_id NOT IN (?)', included_products&.map(&:variants)&.flatten&.map(&:id))

      excluded_line_items.each { |l| l.calculate_promo_total }
    else
      # create LineItemsPromotion if available
      line_items.each { |l| l.calculate_promo_total }
    end

    # calculate the promotion total_discount_amount
    promotions = orders_promotions || []
    promotions << line_items.map(&:line_items_promotions).flatten

    total_discount_amount = promotions&.map(&:discount_amount)&.inject(:+)

    self.line_item_total = line_items&.map(&:line_item_total)&.inject(:+)
    self.promo_total = line_item_total - total_discount_amount
    save!
  end
end
