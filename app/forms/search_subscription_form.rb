class SearchSubscriptionForm
  ALLOWED_COLUMNS = %w[name plan price start_date end_date billing_day_of_month]
  ALLOWED_DIRECTIONS = %w[asc desc]

  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :filter_column, :string
  attribute :text_filter_value, :string
  attribute :text_filter_pattern, :string
  attribute :date_filter_start, :date
  attribute :date_filter_end, :date
  attribute :date_filter_pattern, :string
  attribute :first_column, :string
  attribute :first_direction, :string
  attribute :second_column, :string
  attribute :second_direction, :string
  attribute :page, :integer

  validates :first_column, :second_column, :filter_column,
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
    if filter_params_present?
      scope = build_search_query.call(scope)
    end

    if sort_params_present?
      scope = build_order_query.call(scope)
    end

    scope.paginate(page: page, per_page: 5)
  end

  private

  def build_search_query
    if text_filter?
      filter_by_text
    elsif date_filter?
      filter_by_date
    else
      ->(scope) { scope.where(Subscription.arel_table[filter_column.to_sym].matches("%#{ActiveRecord::Base.sanitize_sql_like(text_filter_value)}%")) }
    end
  end

  def filter_by_text
    if text_filter_pattern == "partial"
      ->(scope) { scope.where(Subscription.arel_table[filter_column.to_sym].matches("%#{ActiveRecord::Base.sanitize_sql_like(text_filter_value)}%")) }
    elsif text_filter_pattern == "exact"
      ->(scope) { scope.where(Subscription.arel_table[filter_column.to_sym].eq(text_filter_value)) }
    elsif text_filter_pattern == "start_with"
      ->(scope) { scope.where(Subscription.arel_table[filter_column.to_sym].matches("#{ActiveRecord::Base.sanitize_sql_like(text_filter_value)}%")) }
    elsif text_filter_pattern == "end_with"
      ->(scope) { scope.where(Subscription.arel_table[filter_column.to_sym].matches("%#{ActiveRecord::Base.sanitize_sql_like(text_filter_value)}")) }
    else
      ->(scope) { scope.where(Subscription.arel_table[filter_column.to_sym].matches("%#{ActiveRecord::Base.sanitize_sql_like(text_filter_value)}%")) }
    end
  end

  def filter_by_date
    if date_filter_pattern == "exact"
      ->(scope) { scope.where(Subscription.arel_table[filter_column.to_sym].eq(date_filter_start)) }
    elsif date_filter_pattern == "before"
      ->(scope) { scope.where(Subscription.arel_table[filter_column.to_sym].lt(date_filter_start)) }
    elsif date_filter_pattern == "after"
      ->(scope) { scope.where(Subscription.arel_table[filter_column.to_sym].gt(date_filter_start)) }
    elsif date_filter_pattern == "between"
      ->(scope) { scope.where(Subscription.arel_table[filter_column.to_sym].gteq(date_filter_start).and(Subscription.arel_table[filter_column.to_sym].lteq(date_filter_end))) }
    else
      ->(scope) { scope.where(Subscription.arel_table[filter_column.to_sym].eq(date_filter_start)) }
    end
  end

  def build_order_query
    orders = build_orders
    ->(scope) { scope.order(orders) }
  end

  def text_filter?
    column_type == :string
  end

  def date_filter?
    column_type == :date || column_type == :decimal
  end

  def column_type
    Subscription.columns_hash[filter_column]&.type
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

  def filter_params_present?
    return false unless filter_column.present?

    if text_filter?
      text_filter_value.present?
    elsif date_filter?
      date_filter_start.present?
    else
      text_filter_value.present?
    end
  end

  def sort_params_present?
    first_column.present? && first_direction.present? ||
    second_column.present? && second_direction.present?
  end
end
