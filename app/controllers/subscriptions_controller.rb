class SubscriptionsController < ApplicationController
  before_action :logged_in_user
  before_action :correct_user
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

  private

  def correct_user
    @user = User.find_by(id: params[:user_id])
    unless @user == current_user
      flash[:danger] = "権限がありません"
      redirect_to root_path, status: :forbidden
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
end
