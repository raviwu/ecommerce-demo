class CreateLineItemsPromotions < ActiveRecord::Migration[5.0]
  def change
    create_table :line_items_promotions do |t|
      t.references :line_item, foreign_key: true, index: true, null: false
      t.references :promotion, foreign_key: true, index: true, null: false

      t.timestamp null: false
    end
  end
end
