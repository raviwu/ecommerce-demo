class CreateShipments < ActiveRecord::Migration[5.0]
  def change
    create_table :shipments do |t|
      t.string :logistics_number, null: false
      t.references :user, foreign_key: true, index: true, null: false
      t.integer :handle_staff_id, null: false
      t.string :shipment_method, null: false
      t.string :status, null: false

      t.datetime :delivered_at
      t.datetime :arrived_at

      t.timestamps null: false
    end

    add_foreign_key :shipments, :users, column: :handle_staff_id
  end
end
