FactoryGirl.define do
  factory :invoice do
    invoice_number { "#{Time.current.to_i.to_s.rjust(20, "0")}#{SecureRandom.random_number(999).to_s.rjust(3, "0")}" }

    association :payment
  end
end
