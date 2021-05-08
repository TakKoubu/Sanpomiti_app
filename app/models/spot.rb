class Spot < ApplicationRecord
  belongs_to :walkcourse
  validates :name, length: { maximum: 50 }
  validates :address, length: { maximum: 50 }
  validates :description, length: { maximum: 250 }
  validates :transit_time, format: { with: /\A[0-9]+\z/ }
  validates :time_required, format: { with: /\A[0-9]+\z/ }
  mount_uploader :spotpic, SpotpicUploader
  geocoded_by :address
  after_validation :geocode, if: :address_changed?
end
