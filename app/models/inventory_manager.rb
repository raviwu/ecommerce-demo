class InventoryManager
  BUFFER_UNIT = Settings.inventory.buffer_unit

  def self.check_free_unit(variant)
    real_count = InventoryUnit.where(variant: variant, status: Settings.inventory.status.free).count
    report_count = real_count - BUFFER_UNIT
    report_count >= 0 ? report_count : 0
  end

  def self.reserve_unit
  end

  def self.release_unit(options = {})
    variant = options[:variant]
    quantity = options[:quantity]
    raise "Provide Variant Object in :variant option" unless variant.kind_of? Variant
    raise "Provide Integer in :quantity option" unless quantity.kind_of? Integer

    InventoryUnit.transaction do
      InventoryUnit.where(
        variant: variant,
        status: Settings.inventory.status.lock
      )
        .limit(quantity)
        .update_all(status: Settings.inventory.status.free)
    end

    variant.save # update cache
  end
end
