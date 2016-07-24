class VariantAsset < ActiveRecord::Base
  belongs_to :variant

  has_attached_file :attachment, styles: { thumb: "303x303>" }

  validates_attachment(
    :attachment,
    presence: true,
    content_type: { content_type: /\Aimage\/.*\Z/ },
    size: { in: 0..2.megabytes }
  )
end
