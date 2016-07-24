FactoryGirl.define do
  factory :variant_asset do
    description "Description of an attachment"
    position 0

    association :variant

    attachment_file_name { 'test.jpg' }
    attachment_content_type { 'image/jpeg' }
    attachment_file_size { 1024 }
    attachment_updated_at { Time.current }
  end
end
