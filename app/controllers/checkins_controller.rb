class CheckinsController < ApplicationController
  # before_action :set_turbo_frame_variant
  before_action :authenticate_user!
  before_action :set_stay
  before_action :set_checkin, only: %i[show edit update destroy]
  

  def index
    @checkins = @stay.checkins.order(checked_at: :desc)
  end

  def show; end

  def new
  @checkin = @stay.checkins.build
  # 【✅ 複雑な respond_to ブロックを削除し、シンプルに】
  # new.turbo_frame.html.erb が自動的に選択されます。
end

# before_action :set_turbo_frame_variant は不要になりますので、削除またはコメントアウトしてください。

  def create
    @checkin = @stay.checkins.new
    merge_structured_json!(@checkin)

    if @checkin.save
      redirect_to stay_checkins_path(@stay), notice: I18n.t("checkins.notices.created"), status: :see_other
    else
      flash.now[:alert] = I18n.t("checkins.notices.create_failed")
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    # URLから「どの予約」の「どの日」かを特定します
    @stay = Stay.find(params[:stay_id])
    @checkin = @stay.checkins.find(params[:id])
  end

  def update
    @stay = Stay.find(params[:stay_id])
    @checkin = @stay.checkins.find(params[:id])

    # 報告内容（テキストと画像）を更新
    if @checkin.update(checkin_params)
      redirect_to stay_path(@stay), notice: "日報を送信しました！✨"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @checkin.destroy
    redirect_to stay_checkins_path(@stay), notice: I18n.t("checkins.notices.destroyed"), status: :see_other
  end

  private

  def set_turbo_frame_variant
    puts "Turbo Frame Request Detected: #{turbo_frame_request?}"
    # Turbo Frameからのリクエストなら、:turbo_frame ビューを使うよう明示
    request.variant = :turbo_frame if turbo_frame_request?
  end
  
  def set_stay
  @stay = Stay.find(params[:stay_id])
  # 【✅ 認可ロジックを復元】
  unless @stay.owner_id == current_user.id
    head :forbidden 
    return # ★ return を追加して、indexなどのアクションへ進むのを防ぐ
  end
end

  def set_checkin
    @checkin = @stay.checkins.find(params[:id])
  end

  # 画面から受け取る“フラットな”入力
  def checkin_params
    # report: 本文, images: 写真（複数可）
    params.require(:checkin).permit(:report, images: [])
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

    # meds（排他ルール）
    bool = ActiveModel::Type::Boolean.new
    none  = bool.cast(p[:meds_none])
    given = bool.cast(p[:meds_given])
    v3    = bool.cast(p[:vaccine_3rd])

    if none
      # 投与なしのときは他の入力を無視
      checkin.meds = { "none" => true, "vaccine_3rd" => v3 }.compact
    else
      meds = {}
      meds["given"]       = true if given
      meds["vaccine_3rd"] = true if v3
      meds["name"]        = p[:meds_name] if p[:meds_name].present?
      meds["dose"]        = p[:meds_dose] if p[:meds_dose].present?
      checkin.meds = meds.presence
    end
  end
end
