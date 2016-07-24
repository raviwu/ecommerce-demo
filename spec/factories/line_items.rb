FactoryGirl.define do
  factory :line_item do
    unit_price 100
    quantity 1
    line_item_total 100
    lock_inventory true

    association :order
    association :variant
    association :currency
  end
end
