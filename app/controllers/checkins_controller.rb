class CheckinsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_stay
  before_action :set_checkin, only: [:show, :edit, :update, :destroy]

  def index
    @checkins = @stay.checkins.order(checked_at: :desc)
  end

  def show
  end

  def new
    @checkin = @stay.checkins.build(checked_at: Time.current)
  end

  def create
    @checkin = @stay.checkins.build(checkin_params)
    # 現在のログインユーザー（シッター）を記録する場合
    @checkin.user = current_user

    if @checkin.save
      redirect_to stay_path(@stay), notice: 'レポートを作成しました！'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @checkin.update(checkin_params)
      # 更新後は、一覧ではなく「作成したレポートの詳細画面」に行くと確認しやすいです
      redirect_to stay_checkin_path(@stay, @checkin), notice: 'レポートを更新しました！'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @checkin.destroy
    redirect_to stay_path(@stay), notice: 'レポートを削除しました'
  end

  private

  def set_stay
    @stay = Stay.find(params[:stay_id])
  end

  def set_checkin
    @checkin = @stay.checkins.find(params[:id])
  end

  def checkin_params
    # ↓↓↓ ここに :mood が入っていることが超重要です！！ ↓↓↓
    params.require(:checkin).permit(:report, :checked_at, :food, :mood, :pee_count, :poop_count, images: [])
  end
end