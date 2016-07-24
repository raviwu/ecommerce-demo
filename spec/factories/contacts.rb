FactoryGirl.define do
  factory :contact do
    attn_name { FFaker::Name.name }
    email { FFaker::Internet.email }
    phone { FFaker::PhoneNumber.phone_number }
    address { "#{FFaker::Address.street_address}, #{FFaker::Address.city}" }
    zipcode { FFaker::AddressUS.zip_code }

    association :user, factory: :customer
  end
end
