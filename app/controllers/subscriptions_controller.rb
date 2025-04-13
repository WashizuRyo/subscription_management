class SubscriptionsController < ApplicationController
  before_action :logged_in_user
  before_action :correct_user
  def new
    @subscription = current_user.subscriptions.new
  end

  private

  def correct_user
    @user = User.find_by(id: params[:user_id])
    unless @user == current_user
      flash[:danger] = "権限がありません"
      redirect_to root_path, status: :forbidden
    end
  end
end
