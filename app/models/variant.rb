class Variant < ActiveRecord::Base
  belongs_to :currency
  belongs_to :product

  has_many :variant_assets, dependent: :destroy

  store :properties, coder: JSON

  validates :price, presence: true
  validates :currency, presence: true
  validates :product, presence: true

  validate :properties_conform_to_product

  def properties_conform_to_product
    return unless product.present?
    check_fields = properties.keys
    check_fields.each do |field|
      allowed_values = product.properties[field]
      errors.add(field, "allow only '#{allowed_values.join(",")}'") unless allowed_values.include? properties[field]
    end
  end
end
