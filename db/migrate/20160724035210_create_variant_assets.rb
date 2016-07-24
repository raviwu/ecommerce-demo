class CreateVariantAssets < ActiveRecord::Migration[5.0]
  def change
    create_table :variant_assets do |t|
      t.string :description
      t.integer :position
      t.attachment :attachment, null: false
      t.references :variant, foreign_key: true, index: true, null: false

      t.timestamps null: false
    end
  end
end
