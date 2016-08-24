FactoryGirl.define do
  factory :promotion do
    scope { Settings.promotion.scope.line_item }
    start_at { Time.current }
    expire_at { Time.current + 2.months }
    active true

    factory :line_item_promotion do
      scope { Settings.promotion.scope.line_item }
      description "特定規格商品第二件打六折"
      rule {
        {
          type: :discount_on_total_when_quantity_meets_requirement,
          require_quantity: 2,
          discount_rate: 0.8,
          included_variant_ids: [],
          discount_on_remainer: false
        }
      }
    end

    factory :product_promotion do
      scope { Settings.promotion.scope.product }
      description "相同商品滿 3000 折 300"
      rule {
        {
          type: :discount_on_total_when_total_meets_requirement,
          require_total: 300000,
          discount_rate: 0.9,
          discount_on_remainer: false
        }
      }
    end

    factory :order_promotion do
      scope { Settings.promotion.scope.order }
      description "全店滿 888 打 85 折"
      rule {
        {
          type: :discount_on_total_when_total_meets_requirement,
          require_total: 88800,
          discount_rate: 0.85,
          discount_on_remainer: true
        }
      }
    end
  end
end
