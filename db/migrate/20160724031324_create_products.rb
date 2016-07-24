class CreateProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.string :description
      t.text :properties
      t.datetime :available_on, null: false
      t.datetime :deleted_at
      t.references :classification, foreign_key: true, index: true, null: false

      t.timestamps null: false
    end
  end
end
