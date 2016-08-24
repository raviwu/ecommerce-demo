FactoryGirl.define do
  factory :variant do
    price 10000
    properties {
      {
        connection: "WiFi",
        version: "addon",
        model: "kindle",
        color: "black"
      }
    }

    association :currency
    association :product
  end
end
