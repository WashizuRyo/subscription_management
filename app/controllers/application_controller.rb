class ApplicationController < ActionController::Base
  include SessionsHelper
  def hello
    render "layouts/application"
  end

  private

  def logged_in_user
    unless logged_in?
      flash[:danger] = "ログインしてください"
      redirect_to login_url, status: :see_other
    end
  end
end
