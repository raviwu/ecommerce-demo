class CreateVariants < ActiveRecord::Migration[5.0]
  def change
    create_table :variants do |t|
      t.references :currency, foreign_key: true, index: true, null: false
      t.references :product, foreign_key: true, index: true, null: false
      t.integer :price, null: false
      t.integer :stock_item_count
      t.text :properties

      t.timestamps null: false
    end
  end
end
