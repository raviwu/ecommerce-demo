FactoryGirl.define do
  factory :payment do
    payment_number { "#{Time.current.to_i.to_s.rjust(20, "0")}#{SecureRandom.random_number(999).to_s.rjust(3, "0")}" }

    payment_method "ATM"
    amount 100000
    status "待付款"

    association :user
    association :currency
    association :order
  end
end
