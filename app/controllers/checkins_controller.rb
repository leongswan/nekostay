class CheckinsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_stay

  def index
    @checkins = @stay.checkins.order(checked_at: :desc)
  end

  def show
    @checkin = @stay.checkins.find(params[:id])
  end

  def new
    @checkin = @stay.checkins.new(checked_at: Time.zone.now)
  end

  def create
    @checkin = @stay.checkins.new(checkin_params)
    if normalize_json!(@checkin) && @checkin.save
      redirect_to stay_checkin_path(@stay, @checkin), notice: "チェックインを登録しました。"
    else
      flash.now[:alert] = "保存に失敗しました。入力内容をご確認ください。"
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_stay
    @stay = Stay.find(params[:stay_id])
    # 権限：オーナー本人のみ閲覧/作成可（必要に応じて調整）
    head :forbidden unless @stay.owner_id == current_user.id
  end

  def checkin_params
    params.require(:checkin).permit(
      :checked_at, :weight, :memo,
      :meal_raw, :litter_raw, :meds_raw
    )
  end

  # 文字列フォーム → JSON 変換
  def normalize_json!(checkin)
    %i[meal litter meds].each do |field|
      raw_key = :"#{field}_raw"
      raw = params[:checkin][raw_key]
      next if raw.blank?

      begin
        parsed = JSON.parse(raw)
      rescue JSON::ParserError
        checkin.errors.add(field, "JSON の形式が不正です")
        return false
      end
      checkin.send("#{field}=", parsed)
    end
    true
  end
end
