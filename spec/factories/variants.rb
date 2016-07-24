FactoryGirl.define do
  factory :variant do
    price 10000
    properties {
      {
        color: "red",
        bandwidth: "5G"
      }
    }

    association :currency
    association :product
  end
end
