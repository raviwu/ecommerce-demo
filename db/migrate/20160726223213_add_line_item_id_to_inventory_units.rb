class AddLineItemIdToInventoryUnits < ActiveRecord::Migration[5.0]
  def change
    add_column :inventory_units, :line_item_id, :integer

    add_foreign_key :inventory_units, :line_items
  end
end
