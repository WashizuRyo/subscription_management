class SubscriptionsController < ApplicationController
  before_action :logged_in_user
  before_action :correct_user
  before_action :get_subscription, only: %i[edit update destroy]

  def index
    search_column = search_subscription_params[:search_column]
    search_value = search_subscription_params[:search_value]
    first_column = search_subscription_params[:first_column]
    first_direction = search_subscription_params[:first_direction]
    second_column = search_subscription_params[:second_column]
    second_direction = search_subscription_params[:second_direction]
    page = search_subscription_params[:page] || 1

    orders = []
    orders << { first_column => first_direction == "asc" ? "asc" : "desc" } if first_column.present?
    orders << { second_column => second_direction == "asc" ? "asc" : "desc" } if second_column.present?

    begin
      validated_orders = Subscription.allowed_sort_orders(orders) if orders.present?
      @subscriptions = current_user.search_subscriptions(search_column: search_column,
                                                         search_value: search_value,
                                                         page: page,
                                                         order_by: validated_orders)
    rescue ArgumentError => e
      flash.now[:danger] = e
      @subscriptions = current_user.subscriptions.paginate(page: page, per_page: 5)
      render "index"
    end
  end

  def new
    @subscription = current_user.subscriptions.new
  end

  def create
    @subscription = current_user.subscriptions.new(subscription_params)
    if @subscription.save
      flash[:success] = "サブスクリプションが登録されました"
      redirect_to root_path
    else
      render "new", status: :unprocessable_entity
    end
  end

  def edit
    if @subscription.nil?
      flash[:danger] = "サブスクリプションが見つかりませんでした"
      redirect_to root_path
    else
      @tags = Tag.all
    end
  end

  def update
    if @subscription.update(subscription_params)
      flash[:success] = "サブスクリプションを更新しました"
      redirect_to root_path
    else
      render "edit", status: :unprocessable_entity
    end
  end

  def destroy
    if @subscription.destroy
      flash[:success] = "サブスクリプションを削除しました"
      redirect_to user_subscriptions_path(current_user)
    else
      flash[:danger] = "サブスクリプションの削除に失敗しました"
      redirect_to user_subscription_path(current_user)
    end
  end

  private

  def correct_user
    @user = User.find_by(id: params[:user_id])
    unless @user == current_user
      flash[:danger] = "権限がありません"
      redirect_to root_path
    end
  end

  def subscription_params
    params.require(:subscription).permit(:subscription_name,
                                         :plan_name,
                                         :price,
                                         :start_date,
                                         :end_date,
                                         :billing_date,
                                         tag_ids: [])
  end

  def get_subscription
    @subscription = Subscription.find_by(id: params[:id])
  end

  def search_subscription_params
    params.permit(:search_column,
                  :search_value,
                  :first_column,
                  :first_direction,
                  :second_column,
                  :second_direction,
                  :page)
  end
end
