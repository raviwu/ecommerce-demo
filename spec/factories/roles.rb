FactoryGirl.define do
  factory :role do
    name { |n| "Role #{n}" }

    factory :admin_role do
      name { Settings.roles.admin }
    end

    factory :customer_role do
      name { Settings.roles.customer }
    end
  end
end
