class CreateOrders < ActiveRecord::Migration[5.0]
  def change
    create_table :orders do |t|
      t.string :order_number, null: false, unique: true
      t.references :user, foreign_key: true, index: true, null: false
      t.text :billing_contact_info, null: false
      t.text :shipping_contact_info, null: false
      t.references :currency, foreign_key: true, index: true, null: false
      t.references :shipment, foreign_key: true, index: true, null: true

      t.integer :line_item_total, null: false, default: 0
      t.integer :promo_total, null: false, default: 0

      t.string :status, null: false
      t.datetime :completed_at

      t.timestamps null: false
    end
  end
end
