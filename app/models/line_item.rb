class LineItem < ActiveRecord::Base
  belongs_to :order
  belongs_to :variant
  belongs_to :currency

  has_many :inventory_units

  validates :order, presence: true
  validates :variant, presence: true
  validates :currency, presence: true
  validates :unit_price, presence: true
  validates :quantity, presence: true
  validates :lock_inventory, presence: true
  validates :line_item_total, presence: true

  validate :check_inventory_unit

  before_save :calculate_line_item_total, :reserve_inventory_unit
  before_destroy :release_inventory_unit

  private

  def calculate_line_item_total
    self.unit_price = unit_price || 0
    self.quantity = quantity || 0

    self.line_item_total = unit_price * quantity
  end

  def check_inventory_unit
    return unless lock_inventory
    return false if quantity.nil? || variant.nil?

    updated_record_attributes = attributes

    updated_record_quantity = updated_record_attributes["quantity"]
    existed_record_quantity = reload.attributes["quantity"] if id.present?

    if id.blank? && quantity > variant.realtime_stock_item_count
      alert_inventory_shortage
    elsif existed_record_quantity.present? && updated_record_quantity > existed_record_quantity
      alert_inventory_shortage if (updated_record_quantity - existed_record_quantity) > variant.realtime_stock_item_count
    end

    assign_attributes(updated_record_attributes)
  end

  def alert_inventory_shortage
    errors.add(:quantity, "cannot exceed inventory quantity: #{variant.stock_item_count}")
  end

  def reserve_inventory_unit
    return unless lock_inventory
    if id.blank?
      check_inventory_unit

      if valid?
        reserved_inventory_units = variant.inventory_units.where(status: Settings.inventory.status.free).limit(quantity)
        reserved_inventory_units.update_all(status: Settings.inventory.status.lock)
        variant.save #update cache
      end
    else
      updated_record_attributes = attributes
      updated_record_quantity = updated_record_attributes["quantity"]
      existed_record_quantity = reload.attributes["quantity"]

      if updated_record_quantity > existed_record_quantity
        check_inventory_unit

        if updated_record.valid?
          reserved_inventory_units = variant.inventory_units.where(status: Settings.inventory.status.free).limit(updated_record_quantity - existed_record_quantity)
          reserved_inventory_units.update_all(status: Settings.inventory.status.lock)
          variant.save #update cache
        end
      elsif updated_record_quantity < existed_record_quantity
        release_units_quantity = existed_record_quantity - updated_record_quantity
        release_units_quantity.times do |n|
          variant.inventory_units.first.update(status: Settings.inventory.status.free)
        end
        variant.save #update cache
      end

      self.assign_attributes(updated_record_attributes)
    end
  end

  def release_inventory_unit
    return unless lock_inventory
    quantity.times do |n|
      variant.inventory_units.first.update(status: Settings.inventory.status.free)
    end
    variant.save #update cache
  end
end
