class SubscriptionsController < ApplicationController
  before_action :logged_in_user
  before_action :correct_user
  before_action :get_subscription, only: %i[edit update destroy show]

  def index
    @search_subscription_form = SearchSubscriptionForm.new(search_subscription_params, current_user: current_user)
    unless @search_subscription_form.valid?
      return @subscriptions = []
    end

    @subscriptions = @search_subscription_form.search_subscriptions
  end

  def show
  end

  def new
    @subscription = current_user.subscriptions.new
    @payment_methods = current_user.payment_methods
    @tags = Tag.all
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
      @payment_methods = current_user.payment_methods
    end
  end

  def update
    params[:subscription][:tag_ids] ||= []
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

  def subscription_params
    params.require(:subscription).permit(:name,
      :plan_name,
      :price,
      :status,
      :start_date,
      :end_date,
      :billing_date,
      :payment_method_id,
      tag_ids: [])
  end

  def get_subscription
    @subscription = Subscription.find_by(id: params[:id])
  end

  def search_subscription_params
    params.fetch(:q, {}).permit(:filter_column,
      :text_filter_value,
      :text_filter_pattern,
      :date_filter_start,
      :date_filter_end,
      :date_filter_pattern,
      :first_column,
      :first_direction,
      :second_column,
      :second_direction,
      :page)
  end
end
