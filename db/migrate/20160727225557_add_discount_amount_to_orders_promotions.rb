class AddDiscountAmountToOrdersPromotions < ActiveRecord::Migration[5.0]
  def change
    add_column :orders_promotions, :discount_amount, :integer
  end
end
