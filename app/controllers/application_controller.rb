class ApplicationController < ActionController::Base
  include SessionsHelper

  private

  def logged_in_user
    unless logged_in?
      flash[:danger] = "ログインしてください"
      redirect_to login_url, status: :see_other
    end
  end

  def correct_user
    @user = User.find_by(id: params[:user_id] || params[:id])
    unless @user == current_user
      flash[:danger] = "権限がありません"
      redirect_to root_path
    end
  end
end
