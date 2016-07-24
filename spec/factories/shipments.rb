FactoryGirl.define do
  factory :shipment do
    logistics_number { "#{Time.current.to_i.to_s.rjust(20, "0")}#{SecureRandom.random_number(999).to_s.rjust(3, "0")}" }
    shipment_method "郵局便利袋"
    status "寄出"
    delivered_at { Time.current }

    association :user
    association :handle_staff, factory: :admin
  end
end
