class InventoryManager
  BUFFER_UNIT = Settings.inventory.buffer_unit

  def self.check_free_unit(variant)
    real_count = InventoryUnit.where(variant: variant, status: Settings.inventory.status.free).count
    report_count = real_count - BUFFER_UNIT
    report_count >= 0 ? report_count : 0
  end

  def self.can_reserve?(options = {})
    variant = self.check_variant_input(options)
    quantity = self.check_quantity_input(options)
    self.check_free_unit(variant) >= quantity
  end

  def self.reserve_unit(options = {})
    line_item = self.check_line_item_input(options)
    quantity =
      if options[:quantity].present?
        self.check_quantity_input(options)
      else
        line_item.quantity
      end

    reserved_units_count = line_item.inventory_units.count

    InventoryUnit.transaction do
      if reserved_units_count > quantity
        self.release_unit(line_item: line_item, quantity: reserved_units_count - quantity)
      elsif (reserved_units_count < quantity) && self.check_free_unit(line_item.variant) >= quantity
        InventoryUnit.where(
          variant: line_item.variant,
          status: Settings.inventory.status.free
        )
          .limit(quantity)
          .update_all(
            line_item_id: line_item.id,
            status: Settings.inventory.status.lock
        )
      end
    end

    line_item.variant.save # update cache
  end

  def self.release_unit(options = {})
    line_item = self.check_line_item_input(options)
    quantity =
      if options[:quantity].present?
        self.check_quantity_input(options)
      else
        line_item.quantity
      end

    raise "Release Quantity should be less than or equal to reserved Quantity" unless quantity <= line_item.quantity

    InventoryUnit.transaction do
      InventoryUnit.where(
        line_item: line_item,
        status: Settings.inventory.status.lock
      )
        .limit(quantity)
        .update_all(
          line_item_id: nil,
          status: Settings.inventory.status.free
        )
    end

    line_item.variant.save # update cache
  end

  private

  def self.check_line_item_input(options)
    line_item = options[:line_item]
    raise "Provide LineItem Object in :line_item option" unless line_item.kind_of?(LineItem)
    raise "LineItem does not request to reserve Inventory" unless line_item.lock_inventory
    raise "LineItem does not assign quantity" unless line_item.quantity.present? && line_item.quantity > 0
    line_item
  end

  def self.check_variant_input(options)
    variant = options[:variant]
    raise "Provide Variant Object in :variant option" unless variant.kind_of?(Variant)
    variant
  end

  def self.check_quantity_input(options)
    quantity = options[:quantity]
    raise "Provide Integer in :quantity option" unless quantity.kind_of?(Integer) && quantity >= 0
    quantity
  end
end
