class CreatePayments < ActiveRecord::Migration[5.0]
  def change
    create_table :payments do |t|
      t.string :payment_number, null: false, unique: true
      t.references :order, foreign_key: true, index: true, null: false
      t.references :user, foreign_key: true, index: true, null: false
      t.references :currency, foreign_key: true, index: true, null: false

      t.integer :amount, null: false, default: 0

      t.string :status, null: false
      t.string :payment_method, null: false
      t.datetime :paid_at

      t.timestamps null: false
    end
  end
end
