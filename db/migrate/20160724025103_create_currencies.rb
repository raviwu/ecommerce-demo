class CreateCurrencies < ActiveRecord::Migration[5.0]
  def change
    create_table :currencies do |t|
      t.string :name, null: false
      t.string :symbol, null: false

      t.timestamps null: false
    end
  end
end
