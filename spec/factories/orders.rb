FactoryGirl.define do
  factory :order do
    order_number { "#{Time.current.to_i.to_s.rjust(20, "0")}#{SecureRandom.random_number(999).to_s.rjust(3, "0")}" }
    billing_contact_info {
      {
        attn_name: "Joe Doe",
        email: "joe_doe@email.com",
        phone: "0921345678",
        address: "Some where in Taiwan",
        zipcode: "220"
      }
    }
    shipping_contact_info {
      {
        attn_name: "Joe Doe",
        email: "joe_doe@email.com",
        phone: "0921345678",
        address: "Some where in Taiwan",
        zipcode: "220"
      }
    }
    line_item_total 100000
    promo_total 80000
    status "待付款"

    association :user
    association :currency
    association :shipment
  end
end
