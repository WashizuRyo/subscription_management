class User < ApplicationRecord
  before_save { email&.downcase! }

  has_many :subscriptions, dependent: :destroy
  has_many :payment_methods, dependent: :destroy

  attr_accessor :remember_token
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
            format: { with: VALID_EMAIL_REGEX },
            uniqueness: true
  validates :monthly_budget, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  has_secure_password
  validates :password, length: { minimum: 6 }, unless: :skip_password_validation

  attr_accessor :skip_password_validation

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

  def monthly_subscription_total
    subscriptions.where(status: :active).sum(:price)
  end

  def budget_usage_percentage
    return 0 if monthly_budget.nil? || monthly_budget.zero?
    ((monthly_subscription_total / monthly_budget) * 100).round(1)
  end

  def budget_remaining
    return nil if monthly_budget.nil?
    monthly_budget - monthly_subscription_total
  end
end
