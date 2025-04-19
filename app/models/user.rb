class User < ApplicationRecord
  before_save { email&.downcase! }

  has_many :subscriptions, dependent: :destroy
  attr_accessor :remember_token
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
            format: { with: VALID_EMAIL_REGEX },
            uniqueness: true
  validates :password, length: { minimum: 6 }
  has_secure_password

  def self.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def self.new_token
    SecureRandom.urlsafe_base64
  end
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
    remember_digest
  end

  def session_token
    remember_digest || remember
  end

  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  def search_subscriptions(search_column: nil, search_value: nil, page: 1, order_by: [])
    result = subscriptions

    if search_column.nil? && search_value.nil?
      return result
    end

    unless ALLOWED_COLUMNS.include?(search_column)
      raise ArgumentError, "無効なカラム名です: #{search_column}"
    end

    if search_column == "price"
      result = result.where(
        "#{search_column} LIKE :search_value",
        search_value: search_value
      )
    else
      result = result.where(
        "#{search_column} LIKE :search_value",
        search_value: "%#{search_value}%"
      )
    end

    if order_by.present?
      result = result.order(order_by)
    end

    result.paginate(page: page, per_page: 5)
  end
end
