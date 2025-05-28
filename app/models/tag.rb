class Tag < ApplicationRecord
  has_many :subscription_tags, dependent: :destroy
  has_many :subscriptions, through: :subscription_tags

  validates :name, presence: true

  scope :search_by_name, ->(query) { where("name LIKE ?", "%#{query}%") }
end
