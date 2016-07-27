class CreatePromotions < ActiveRecord::Migration[5.0]
  def change
    create_table :promotions do |t|
      t.string :scope, null: false
      t.string :description, null: false
      t.text :rule, null: false
      t.datetime :start_at, null: false
      t.datetime :expire_at, null: false
      t.boolean :active, null: false, default: false

      t.timestamp null: false
    end
  end
end
