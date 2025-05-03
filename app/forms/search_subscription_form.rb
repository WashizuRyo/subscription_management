class SearchSubscriptionForm
  ALLOWED_COLUMNS = %w[name plan_name price start_date end_date billing_date]
  ALLOWED_DIRECTIONS = %w[asc desc]

  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :search_column, :string
  attribute :search_value, :string
  attribute :first_column, :string
  attribute :first_direction, :string
  attribute :second_column, :string
  attribute :second_direction, :string
  attribute :page, :integer

  validates :first_column, :second_column, :search_column,
            inclusion: { in: ALLOWED_COLUMNS, message: "無効なカラム名です" },
            allow_nil: true
  validates :first_direction, :second_direction,
            inclusion: { in: ALLOWED_DIRECTIONS, message: "無効な並び順です" },
            allow_nil: true

  def initialize(attributes = {}, current_user:)
    blank_to_nil(attributes)
    super(attributes)
    @current_user = current_user
  end

  def search_subscriptions
    return [] unless valid?

    scope = @current_user.subscriptions.includes(:tags, :payment_method)
    scope = apply_search_filter(scope) if search_params_present?
    scope = apply_order(scope) if orders_present?

    scope.paginate(page: page, per_page: 5)
  end

  private

  def apply_search_filter(scope)
    if search_column == "price"
      scope.where(Subscription.arel_table[search_column.to_sym].eq(search_value))
    else
      scope.where(Subscription.arel_table[search_column.to_sym].matches("%#{ActiveRecord::Base.sanitize_sql_like(search_value)}%"))
    end
  end

  def apply_order(scope)
    scope.order(build_orders)
  end

  def build_orders
    orders = []
    orders << { first_column => first_direction } if first_column.present?
    orders << { second_column => second_direction } if second_column.present?
    orders
  end

  def blank_to_nil(attributes)
    attributes.each do |key, value|
      attributes[key] = value.presence
    end
  end

  def search_params_present?
    search_column.present? && search_value.present?
  end

  def orders_present?
    build_orders.present?
  end
end
