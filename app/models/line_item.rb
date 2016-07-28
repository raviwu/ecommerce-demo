class LineItem < ActiveRecord::Base
  belongs_to :order
  belongs_to :variant
  belongs_to :currency

  has_many :inventory_units

  has_many :line_items_promotions, dependent: :destroy
  has_many :promotions, through: :line_items_promotions

  validates :order, presence: true
  validates :variant, presence: true
  validates :currency, presence: true
  validates :unit_price, presence: true
  validates :quantity, presence: true
  validates :lock_inventory, inclusion: { in: [true, false] }
  validates :lock_inventory, exclusion: { in: [nil] }
  validates :line_item_total, presence: true

  validate :check_inventory_unit

  before_save :calculate_line_item_total
  after_save :update_inventory_unit_reservation # already validates inventory_units
  before_destroy :release_inventory_unit

  def calculate_promo_total
    return unless Promotion.active_line_item_promotions.present?
    lock!

    promotion_applied_result = Promotion.assign_promotion_to_line_item(self)

    if promotion_applied_result.present?
      LineItemsPromotion.create(line_item_id: id, promotion_id: promotion_applied_result&.first, discount_amount: promotion_applied_result&.last)

      self.promo_total = line_item_total - promotion_applied_result&.last
    end

    save!
  end

  def calculate_line_item_total
    self.unit_price = unit_price || 0
    self.quantity = quantity || 0

    self.line_item_total = unit_price * quantity
  end

  private

  def check_inventory_unit
    return unless lock_inventory
    return if quantity.nil? || variant.nil?

    if id.blank? # new record
      alert_inventory_shortage unless InventoryManager.can_reserve?(variant: variant, quantity: quantity)
    else
      updated_record_attributes = attributes

      updated_quantity = updated_record_attributes["quantity"]
      existed_quantity = reload.attributes["quantity"]

      increase_quantity = updated_quantity - existed_quantity

      alert_inventory_shortage if increase_quantity > 0 && !InventoryManager.can_reserve?(variant: variant, quantity: increase_quantity)

      assign_attributes(updated_record_attributes)
    end
  end

  def alert_inventory_shortage
    errors.add(:quantity, "cannot exceed inventory quantity: #{variant.stock_item_count}")
  end

  def update_inventory_unit_reservation
    return unless lock_inventory
    check_inventory_unit
    InventoryManager.update_reservation(line_item: self) if valid?
  end

  def release_inventory_unit
    return unless lock_inventory
    InventoryManager.release_unit(line_item: self)
  end
end
