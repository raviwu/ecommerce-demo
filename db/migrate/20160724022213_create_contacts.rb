class CreateContacts < ActiveRecord::Migration[5.0]
  def change
    create_table :contacts do |t|
      t.string :attn_name, null: false
      t.string :email
      t.string :phone
      t.string :address
      t.string :zipcode
      t.references :user, foreign_key: true, index: true, null: false

      t.timestamps null: false
    end
  end
end
