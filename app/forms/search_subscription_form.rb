class SearchSubscriptionForm
  ALLOWED_COLUMNS = %w[subscription_name plan_name price start_date end_date billing_date]
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
            allow_blank: true
  validates :first_direction, :second_direction,
            inclusion: { in: ALLOWED_DIRECTIONS, message: "無効な並び順です" },
            allow_blank: true

  def initialize(attributes = {}, current_user:)
    super(attributes)
    @current_user = current_user
  end

  def search_subscriptions
    validated_orders = build_orders
    result = @current_user.subscriptions

    if search_column.nil? && search_value.nil?
      return result.paginate(page: page, per_page: 5)
    end

    # ソートのみクエリに設定された場合
    if search_column == "" && validated_orders.present?
      return result.order(validated_orders).paginate(page: page, per_page: 5)
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

    if validated_orders.present?
      result = result.order(validated_orders)
    end

    result.paginate(page: page, per_page: 5)
  end

  def build_orders
    return [] unless self.valid?

    orders = []
    orders << { first_column => first_direction } if first_column.present?
    orders << { second_column => second_direction } if second_column.present?
    orders
  end
end
