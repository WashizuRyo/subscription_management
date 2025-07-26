class UsersController < ApplicationController
  before_action :logged_in_user, only: [ :edit, :update ]
  before_action :correct_user, only: [ :edit, :update ]
  before_action :set_user

  def show; end

  def edit; end

  def update
    # パスワードが空の場合はバリデーションをスキップ
    if params[:user][:password].blank?
      @user.skip_password_validation = true
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end

    if @user.update(user_params)
      flash[:success] = "設定を更新しました"
      redirect_to @user
    else
      render "edit", status: :unprocessable_entity
    end
  end

  def new; end

  def create
    if @user.save
      reset_session
      log_in @user
      flash[:success] = "サインアップに成功しました！"
      redirect_to @user
    else
      render "new", status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :monthly_budget)
  end
end
