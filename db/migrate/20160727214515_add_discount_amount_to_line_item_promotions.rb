class AddDiscountAmountToLineItemPromotions < ActiveRecord::Migration[5.0]
  def change
    add_column :line_items_promotions, :discount_amount, :integer
  end
end
