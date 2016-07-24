FactoryGirl.define do
  factory :user do
    email { FFaker::Internet.email }
    name { FFaker::Name.name }
    password "password"
    password_confirmation "password"

    association :role

    factory :customer do
      role { create(:customer_role) }
    end

    factory :admin do
      role { create(:admin_role) }
    end
  end
end
