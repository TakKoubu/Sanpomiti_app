class UsersController < ApplicationController
  before_action :require_user_logged_in, only: [:show, :edit, :likes]
  before_action :set_search

  def show
    @user = User.find(params[:id])
    @walkcourses = current_user.walkcourses.order(id: :desc).page(params[:page]).per(3)
    counts(@user)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      flash[:success] = 'ユーザを登録しました。'
      redirect_to @user
    else
      flash.now[:danger] = 'ユーザの登録に失敗しました。'
      render 'new'
    end
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = 'ユーザー情報の更新に成功しました。'
      redirect_to @user
    else
      flash.now[:danger] = 'ユーザー情報の更新に失敗しました。'
      render 'edit'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def likes
    @user = User.find(params[:id])
    @walkcourses = @user.feed_favorites.order(id: :desc).page(params[:page]).per(3)
    counts(@user)
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :prefecture_id)
  end
end
