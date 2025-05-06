class TagsController < ApplicationController
  before_action :logged_in_user
  before_action :correct_user
  before_action :get_tag, only: %i[destroy edit update]

  def index
    @tags = Tag.all
    @tag = Tag.new
  end

  def edit
    if @tag.nil?
      flash[:danger] = "タグが見つかりませんでした"
      redirect_to user_tags_path(current_user)
    end
  end

  def update
    if @tag.update(tag_params)
      flash[:success] = "タグを更新しました"
      redirect_to user_tags_path(current_user)
    else
      flash.now[:danger] = "タグの更新に失敗しました"
      render "edit", status: :unprocessable_entity
    end
  end

  def destroy
    if @tag.destroy
      flash[:success] = "タグを削除しました"
      redirect_to user_tags_path(current_user)
    else
      flash.now[:danger] = "タグの削除に失敗しました"
      redirect_to user_tags_path(current_user)
    end
  end

  private

  def get_tag
    @tag = Tag.find_by(id: params[:id])
  end

  def tag_params
    params.require(:tag).permit(:name)
  end
end
