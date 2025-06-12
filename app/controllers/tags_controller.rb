class TagsController < ApplicationController
  before_action :logged_in_user
  before_action :correct_user
  before_action :get_tag, only: %i[destroy edit update]

  def index
    @tags = Tag.search_by_name(query_params[:name])
    @tag = Tag.new
  end

  def create
    @tag = Tag.new(tag_params)
    if @tag.save
      flash[:success] = "タグを作成しました"
      redirect_to user_tags_path(current_user)
    else
      @tags = Tag.all
      render "index", status: :unprocessable_entity
    end
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
      @tags = Tag.all
      render "index", status: :unprocessable_entity
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
    params.require(:tag).permit(:name, :color)
  end

  def query_params
    params.permit(:name)
  end
end
