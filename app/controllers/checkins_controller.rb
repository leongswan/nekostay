class CheckinsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_stay
  before_action :set_checkin, only: %i[show edit update destroy]

  def index
    @checkins = @stay.checkins.order(checked_at: :desc)
  end

  def show; end

  def new
    @checkin = @stay.checkins.new(checked_at: Time.zone.now)
  end

  def create
    @checkin = @stay.checkins.new
    merge_structured_json!(@checkin)

    if @checkin.save
      redirect_to stay_checkins_path(@stay), notice: "チェックインを登録しました。"
    else
      flash.now[:alert] = "保存に失敗しました。入力内容をご確認ください。"
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    merge_structured_json!(@checkin)

    if @checkin.save
      redirect_to stay_checkins_path(@stay), notice: "チェックインを更新しました。"
    else
      flash.now[:alert] = "更新に失敗しました。"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @checkin.destroy
    redirect_to stay_checkins_path(@stay), notice: "チェックインを削除しました。", status: :see_other
  end

  private

  def set_stay
    @stay = Stay.find(params[:stay_id])
    head :forbidden unless @stay.owner_id == current_user.id
  end

  def set_checkin
    @checkin = @stay.checkins.find(params[:id])
  end

  # 画面から受け取る“フラットな”入力
  def checkin_params
    params.require(:checkin).permit(
      :checked_at, :weight, :memo,
      :meal_amount, :meal_brand,
      :litter_clumps, :litter_pee,
      :meds_name, :meds_dose, :meds_given, :meds_none, :vaccine_3rd
    )
  end

  # Strong Params → JSON カラムへ詰め替え
  def merge_structured_json!(checkin)
    p = checkin_params

    # 基本項目
    checkin.assign_attributes(p.slice(:checked_at, :weight, :memo))

    # meal
    meal = {
      "amount" => p[:meal_amount].presence,
      "brand"  => p[:meal_brand].presence
    }.compact
    checkin.meal = meal.presence

    # litter
    litter = {
      "clumps" => p[:litter_clumps].presence&.to_i,
      "pee"    => p[:litter_pee].presence&.to_i
    }.compact
    checkin.litter = litter.presence

    # meds
    meds_none   = ActiveModel::Type::Boolean.new.cast(p[:meds_none])
    meds_given  = ActiveModel::Type::Boolean.new.cast(p[:meds_given])
    vaccine_3rd = ActiveModel::Type::Boolean.new.cast(p[:vaccine_3rd])

    if meds_none
      # 「投与なし」優先（他の入力は無視）
      checkin.meds = { "none" => true, "vaccine_3rd" => (vaccine_3rd || nil) }.compact
    else
      meds = {
        "name" => p[:meds_name].presence,
        "dose" => p[:meds_dose].presence
      }.compact
      meds["given"]       = true if meds_given
      meds["vaccine_3rd"] = true if vaccine_3rd
      checkin.meds = meds.presence
    end
  end
end
