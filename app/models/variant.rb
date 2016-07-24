class Variant < ActiveRecord::Base
  belongs_to :currency
  belongs_to :product

  has_many :variant_assets, dependent: :destroy
  has_many :inventory_units, dependent: :destroy

  store :properties, coder: JSON

  validates :price, presence: true
  validates :currency, presence: true
  validates :product, presence: true

  validate :properties_conform_to_product

  before_save :update_stock_item_count

  private

  def properties_conform_to_product
    return unless product.present?
    check_fields = properties.keys
    check_fields.each do |field|
      allowed_values = product.properties[field]
      errors.add(field, "allow only '#{allowed_values.join(",")}'") unless allowed_values.include? properties[field]
    end
  end

  def update_stock_item_count
    self.stock_item_count = self.inventory_units.where(status: Settings.inventory.status.free).count
  end
end
