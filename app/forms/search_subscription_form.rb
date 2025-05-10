class SearchSubscriptionForm
  ALLOWED_COLUMNS = %w[name plan_name price start_date end_date billing_date]
  ALLOWED_DIRECTIONS = %w[asc desc]

  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :search_column, :string
  attribute :search_value, :string
  attribute :search_value_pattern, :string
  attribute :search_date_start, :date
  attribute :search_date_end, :date
  attribute :search_date_value_pattern, :string
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
    attributes = blank_to_nil(attributes)
    super(attributes)
    @current_user = current_user
  end

  def search_subscriptions
    return [] unless valid?

    scope = @current_user.subscriptions.includes(:tags, :payment_method)
    if search_params_present?
      scope = build_search_query.call(scope)
    end

    if sort_params_present?
      scope = build_order_query.call(scope)
    end

    scope.paginate(page: page, per_page: 5)
  end

  private

  def build_search_query
    if search_value_pattern.present? && column_type == :string
      filter_by_string
    elsif search_date_value_pattern.present? && (column_type == :date || column_type == :decimal)
      filter_by_date
    else
      ->(scope) { scope.where(Subscription.arel_table[search_column.to_sym].matches("%#{ActiveRecord::Base.sanitize_sql_like(search_value)}%")) }
    end
  end

  def filter_by_string
    if search_value_pattern == "partial"
      ->(scope) { scope.where(Subscription.arel_table[search_column.to_sym].matches("%#{ActiveRecord::Base.sanitize_sql_like(search_value)}%")) }
    elsif search_value_pattern == "exact"
      ->(scope) { scope.where(Subscription.arel_table[search_column.to_sym].eq(search_value)) }
    elsif search_value_pattern == "start_with"
      ->(scope) { scope.where(Subscription.arel_table[search_column.to_sym].matches("#{ActiveRecord::Base.sanitize_sql_like(search_value)}%")) }
    elsif search_value_pattern == "end_with"
      ->(scope) { scope.where(Subscription.arel_table[search_column.to_sym].matches("%#{ActiveRecord::Base.sanitize_sql_like(search_value)}")) }
    end
  end

  def filter_by_date
    if search_date_value_pattern == "exact"
      ->(scope) { scope.where(Subscription.arel_table[search_column.to_sym].eq(search_date_start)) }
    elsif search_date_value_pattern == "before"
      ->(scope) { scope.where(Subscription.arel_table[search_column.to_sym].lt(search_date_start)) }
    elsif search_date_value_pattern == "after"
      ->(scope) { scope.where(Subscription.arel_table[search_column.to_sym].gt(search_date_start)) }
    elsif search_date_value_pattern == "between"
      ->(scope) { scope.where(Subscription.arel_table[search_column.to_sym].gteq(search_date_start).and(Subscription.arel_table[search_column.to_sym].lteq(search_date_end))) }
    end
  end

  def build_order_query
    orders = build_orders
    ->(scope) { scope.order(orders) }
  end

  def column_type
    Subscription.columns_hash[search_column]&.type
  end

  def build_orders
    orders = []
    orders << { first_column => first_direction } if first_column.present?
    orders << { second_column => second_direction } if second_column.present?
    orders
  end

  def blank_to_nil(attributes)
    attributes.transform_values { |v| v.presence }
  end

  def search_params_present?
    search_column.present? && search_value.present?
  end

  def sort_params_present?
    first_column.present? && first_direction.present? ||
    second_column.present? && second_direction.present?
  end
end
