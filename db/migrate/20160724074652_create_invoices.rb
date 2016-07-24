class CreateInvoices < ActiveRecord::Migration[5.0]
  def change
    create_table :invoices do |t|
      t.string :invoice_number, null: false, unique: true
      t.references :payment, foreign_key: true, index: true, null: false

      t.timestamps null: false
    end
  end
end
