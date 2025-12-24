class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show, :edit, :update]
  before_action :ensure_correct_user, only: [:edit, :update]

  # マイページ（プロフィール表示）
  def show
    # 自分が関わっている予約などを取得（マイページに表示するため）
    @my_stays = current_user.stays.order(start_on: :desc)
    @sitter_jobs = current_user.sitter_stays.order(start_on: :desc)
  end

  # 編集画面
  def edit
  end

  # 更新処理
  def update
    if @user.update(user_params)
      redirect_to user_path(@user), notice: 'プロフィールを更新しました！✨'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  # 本人だけが編集できるようにするガード
  def ensure_correct_user
    unless @user == current_user
      redirect_to user_path(@user), alert: '他のユーザーのプロフィールは編集できません'
    end
  end

  def user_params
    params.require(:user).permit(:name, :introduction, :image)
  end
end
