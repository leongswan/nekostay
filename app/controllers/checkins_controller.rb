class CheckinsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_stay
  before_action :set_checkin, only: %i[show destroy]   # ← show/destroy だけ

  def index
    @checkins = @stay.checkins.order(checked_at: :desc)
  end

  def show
  end

  def new
    @checkin = @stay.checkins.new(checked_at: Time.zone.now)
  end

  def create
    @checkin = @stay.checkins.new(checkin_params)
    if normalize_json!(@checkin) && @checkin.save
      redirect_to stay_checkin_path(@stay, @checkin), notice: "チェックインを登録しました。"
    else
      flash.now[:alert] = "保存に失敗しました。"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @checkin.destroy
    redirect_to stay_checkins_path(@stay), notice: "削除しました。"
  end

  private

  def set_stay
    @stay = Stay.find(params[:stay_id])
    head :forbidden unless @stay.owner_id == current_user.id
  end

  def set_checkin
    @checkin = @stay.checkins.find(params[:id])
  end

  def checkin_params
    params.require(:checkin).permit(:checked_at, :weight, :mood, :memo,
                                    :meal_raw, :litter_raw, :meds_raw)
  end

  # *_raw を JSON に変換してセット
  def normalize_json!(checkin)
    %i[meal litter meds].each do |field|
      raw = params.dig(:checkin, :"#{field}_raw")
      next if raw.blank?
      begin
        parsed = JSON.parse(raw)
      rescue JSON::ParserError
        checkin.errors.add(field, "JSON の形式が不正です")
        return false
      end
      checkin.public_send("#{field}=", parsed)
    end
    true
  end
end
