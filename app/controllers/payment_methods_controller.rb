class PaymentMethodsController < ApplicationController
  before_action :logged_in_user
  before_action :correct_user
  before_action :get_payment_method, only: %i[update destroy]
  before_action :set_payment_methods, only: %i[update create]

  def index
    @payment_method = current_user.payment_methods.new
    @payment_methods = current_user.payment_methods.search_by_provider_or_type(query_params[:q])
  end

  def create
    @payment_method = current_user.payment_methods.new(payment_method_params)
    if @payment_method.save
      flash[:success] = "支払い方法の登録に成功しました"
      redirect_to user_payment_methods_path(current_user)
    else
      render :index, status: :unprocessable_entity
    end
  end

  def update
    if @payment_method.update(payment_method_params)
      flash[:success] = "支払い方法の更新に成功しました"
      redirect_to user_payment_methods_path(current_user)
    else
      @error_payment_method = @payment_method
      @payment_method = current_user.payment_methods.new
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    if @payment_method.destroy
      flash[:success] = "支払い方法の削除に成功しました"
      redirect_to user_payment_methods_path(current_user)
    else
      flash[:success] = "支払い方法の削除に失敗しました"
      redirect_to user_payment_methods_path(current_user)
    end
  end

  private

  def payment_method_params
    params.require(:payment_method).permit(:method_type,
                                          :provider,
                                          :memo)
  end

  def get_payment_method
    @payment_method = PaymentMethod.find_by(id: params[:id])
  end

  def set_payment_methods
    @payment_methods = current_user.payment_methods
  end

  def query_params
    params.permit(:q)
  end
end
