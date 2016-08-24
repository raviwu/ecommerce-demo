FactoryGirl.define do
  factory :product do
    name "AT&T 4G Phone Card"
    description "The best devices for reading, period."
    properties {
      {
        connection: %w(3G WiFi),
        version: %w(addon addfree),
        model: %W(kindle paperwhite voyage oasis),
        color: %W(black white)
      }
    }
    available_on { Time.current }

    association :classification
  end
end
