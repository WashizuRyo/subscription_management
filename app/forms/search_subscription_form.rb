class SearchSubscriptionForm
  ALLOWED_COLUMNS = %w[name plan price start_date end_date billing_day_of_month]
  ALLOWED_DIRECTIONS = %w[asc desc]

  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :filter_column, :string
  attribute :text_filter_value, :string
  attribute :text_filter_pattern, :string
  attribute :date_filter_start, :string
  attribute :date_filter_end, :string
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
    elsif range_filter?
      filter_by_range
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

  def filter_by_range
    column = Subscription.arel_table[filter_column.to_sym]
    start_value = parse_range_value(date_filter_start, :start)
    end_value = if date_filter_pattern == "between"
      parse_range_value(date_filter_end, :end)
    end

    return ->(scope) { scope.none } if start_value.nil?

    case date_filter_pattern
    when "exact"
      ->(scope) { scope.where(column.eq(start_value)) }
    when "before"
      ->(scope) { scope.where(column.lt(start_value)) }
    when "after"
      ->(scope) { scope.where(column.gt(start_value)) }
    when "between"
      return ->(scope) { scope.none } if end_value.nil?

      ->(scope) { scope.where(column.gteq(start_value).and(column.lteq(end_value))) }
    else
      ->(scope) { scope.where(column.eq(start_value)) }
    end
  end

  def build_order_query
    orders = build_orders
    ->(scope) { scope.order(orders) }
  end

  def text_filter?
    column_type == :string
  end

  def range_filter?
    column_type.in?([:date, :decimal, :integer])
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
    elsif range_filter?
      if date_filter_pattern == "between"
        date_filter_start.present? && date_filter_end.present?
      else
        date_filter_start.present?
      end
    else
      text_filter_value.present?
    end
  end

  def sort_params_present?
    first_column.present? && first_direction.present? ||
    second_column.present? && second_direction.present?
  end

  def parse_range_value(value, _position)
    return if value.blank?

    result = cast_range_value(value)
    result
  rescue ArgumentError, TypeError
    errors.add(:base, "無効な検索値です") unless errors[:base].include?("無効な検索値です")
    nil
  end

  def cast_range_value(value)
    type = attribute_type
    return value if type.nil?

    type.deserialize(value).tap do |casted|
      if casted.nil?
        errors.add(:base, "無効な検索値です") unless errors[:base].include?("無効な検索値です")
      end
    end
  end

  def attribute_type
    return if filter_column.blank?

    Subscription.type_for_attribute(filter_column)
  end
end
