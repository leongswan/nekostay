class CheckinsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_stay
  before_action :set_checkin, only: %i[show edit update destroy]

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
      flash.now[:alert] = "保存に失敗しました。入力内容をご確認ください。"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    # 先に通常カラムをセット
    @checkin.assign_attributes(checkin_params)
    # JSON を反映 → バリデーション → 保存
    if normalize_json!(@checkin) && @checkin.save
      redirect_to stay_checkin_path(@stay, @checkin), notice: "チェックインを更新しました。"
    else
      flash.now[:alert] = "更新に失敗しました。入力内容をご確認ください。"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @checkin.destroy
    redirect_to stay_checkins_path(@stay), notice: "チェックインを削除しました。"
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
    params.require(:checkin).permit(:checked_at, :weight, :memo)
                                    
  end

  # *_raw を JSON に変換してセット
  def normalize_json!(checkin)
    %i[meal litter meds].each do |field|
      raw_key = :"#{field}_raw"
      raw = params[:checkin][raw_key] rescue nil
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
