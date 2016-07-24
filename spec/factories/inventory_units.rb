FactoryGirl.define do
  factory :inventory_unit do
    status { Settings.inventory.status.free }

    association :variant
  end
end
