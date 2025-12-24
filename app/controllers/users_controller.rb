class UsersController < ApplicationController
  before_action :authenticate_user!
  # 共通処理：IDからユーザーを特定する (@userに代入)
  before_action :set_user, only: [:show, :edit, :update]
  # 共通処理：本人以外は編集させないガード
  before_action :ensure_correct_user, only: [:edit, :update]

  # マイページ（プロフィール表示）
  def show
    # 自分が飼い主としての予約履歴
    @my_stays = current_user.stays.order(start_on: :desc)
    # 自分がシッターとしての仕事履歴
    @sitter_jobs = current_user.sitter_stays.order(start_on: :desc)
  end

  # 編集画面
  def edit
    # before_action で @user の取得と本人確認は終わっているので
    # ここは空っぽでOKです！自動的に edit.html.erb が表示されます。
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

  def ensure_correct_user
    unless @user == current_user
      # 他人の編集画面に入ろうとしたら、自分のマイページへ強制送還
      redirect_to user_path(current_user), alert: '他のユーザーのプロフィールは編集できません'
    end
  end

  def user_params
    # 名前、自己紹介、画像を許可
    params.require(:user).permit(:name, :introduction, :image)
  end
end