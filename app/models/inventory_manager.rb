class InventoryManager
  BUFFER_UNIT = Settings.inventory.buffer_unit

  def self.check_free_inventory_unit(variant)
    real_count = InventoryUnit.where(variant: variant, status: Settings.inventory.status.free).count
    report_count = real_count - BUFFER_UNIT
    report_count >= 0 ? report_count : 0
  end

  def self.reserve_inventory_unit
  end

  def self.release_inventory_unit
  end
end
