class CreateInventoryUnits < ActiveRecord::Migration[5.0]
  def change
    create_table :inventory_units do |t|
      t.string :status, null: false, default: Settings.inventory.status.free
      t.references :variant, foreign_key: true, index: true, null: false

      t.timestamps null: false
    end
  end
end
