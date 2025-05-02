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
    return [] unless self.valid?

    @orders = build_orders
    user_subscriptions = @current_user.subscriptions.includes(:tags, :payment_method)

    return user_subscriptions.paginate(page: page, per_page: 5) if search_params_nil?
    return user_subscriptions.order(@orders).paginate(page: page, per_page: 5) if only_sort_params_present?

    if search_column == "price"
      user_subscriptions = user_subscriptions.where(
        "#{search_column} LIKE :search_value",
        search_value: search_value
      )
    else
      user_subscriptions = user_subscriptions.where(
        "#{search_column} LIKE :search_value",
        search_value: "%" + ActiveRecord::Base.sanitize_sql_like(search_value) + "%"
      )
    end

    if @orders.present?
      user_subscriptions = user_subscriptions.order(@orders)
    end

    user_subscriptions.paginate(page: page, per_page: 5)
  end

  private

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

  def search_params_nil?
    search_column.nil? ||  search_value.nil?
  end

  def only_sort_params_present?
    @orders.present? && search_params_nil?
  end
end
