class CreateOrdersPromotions < ActiveRecord::Migration[5.0]
  def change
    create_table :orders_promotions do |t|
      t.references :order, foreign_key: true, index: true, null: false
      t.references :promotion, foreign_key: true, index: true, null: false

      t.timestamp null: false
    end
  end
end
