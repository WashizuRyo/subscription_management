class SubscriptionsController < ApplicationController
  before_action :logged_in_user
  before_action :correct_user
  before_action :get_subscription, only: %i[edit update destroy]

  def index
    subscription_name = search_subscription_params[:subscription_name]
    first_column = search_subscription_params[:first_column]
    first_direction = search_subscription_params[:first_direction]
    second_column = search_subscription_params[:second_column]
    second_direction = search_subscription_params[:second_direction]

    orders = []
    orders << { first_column => first_direction == "asc" ? "asc" : "desc" } if first_column.present?
    orders << { second_column => second_direction == "asc" ? "asc" : "desc" } if second_column.present?

    begin
      validated_orders = Subscription.allowed_sort_orders(orders) if orders.present?
    rescue ArgumentError => e
      flash.now[:danger] = e
      @subscriptions = current_user.subscriptions
      render "index"
    end

    @subscriptions = current_user.search_subscriptions(subscription_name: subscription_name,
                                                       order_by: validated_orders)
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
                                         :billing_date)
  end

  def get_subscription
    @subscription = Subscription.find_by(id: params[:id])
  end

  def search_subscription_params
    params.permit(:subscription_name,
                                         :first_column,
                                         :first_direction,
                                         :second_column,
                                         :second_direction)
  end
end
