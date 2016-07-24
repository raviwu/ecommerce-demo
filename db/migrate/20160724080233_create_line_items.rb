class CreateLineItems < ActiveRecord::Migration[5.0]
  def change
    create_table :line_items do |t|
      t.references :order, foreign_key: true, index: true, null: false
      t.references :variant, foreign_key: true, index: true, null: false
      t.references :currency, foreign_key: true, index: true, null: false

      t.integer :unit_price, null: false, default: 0
      t.integer :quantity, null: false, default: 0

      t.boolean :lock_inventory, null: false, default: false

      t.integer :line_item_total, null: false
      t.integer :promo_total

      t.timestamps null: false
    end
  end
end
