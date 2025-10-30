# app/controllers/stays_controller.rb
class StaysController < ApplicationController
  before_action :authenticate_user!
  # 修正: show 以外のアクション（edit, update, destroy）も set_stay を使う
  before_action :set_stay, only: %i[show edit update destroy] 

  def index
    # オーナー本人の Stay を新しい順で
    @stays = Stay.where(owner_id: current_user.id).order(start_on: :desc)
  end

  def show
    # @stay = Stay.find(params[:id]) # <- set_stay が実行するので不要
    @recent_checkins = @stay.checkins.order(checked_at: :desc).limit(3)
  end

  # --- 以下の new アクションを追加 ---
  def new
    @stay = Stay.new
  end

  # --- 以下の create アクションを追加 ---
  def create
    # @stay = Stay.new(stay_params)
    # 修正: owner_id には必ず current_user をセットする
    @stay = current_user.owned_stays.new(stay_params)

    if @stay.save
      
      # --- 💡 StaySplitter の組み込み 💡 ---
      # 保存が成功したら、日数を計算
      duration = (@stay.end_on - @stay.start_on).to_i + 1
      
      # もし日数が14日を超えていたら、分割サービスを呼び出す
      if duration > StaySplitter::MAX_DAYS
        StaySplitter.split!(@stay)
      end
      # --- 組み込みここまで ---
      
      # (status: :see_other は Turbo 用)
      redirect_to stay_path(@stay), notice: "滞在を登録しました。", status: :see_other
    else
      flash.now[:alert] = "保存に失敗しました。入力内容をご確認ください。"
      render :new, status: :unprocessable_entity
    end
  end

  # --- 以下の空のアクションを追加 (scaffold) ---
  def edit
    # @stay = Stay.find(params[:id]) <- set_stay が実行
  end

  def update
    # @stay = Stay.find(params[:id]) <- set_stay が実行
    if @stay.update(stay_params)
      # (TODO: update 時も StaySplitter を呼び出すか検討)
      redirect_to stay_path(@stay), notice: "滞在を更新しました。", status: :see_other
    else
      flash.now[:alert] = "更新に失敗しました。入力内容をご確認ください。"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    # @stay = Stay.find(params[:id]) <- set_stay が実行
    @stay.destroy
    redirect_to stays_path, notice: "滞在を削除しました。", status: :see_other
  end


  private

  def set_stay
    @stay = Stay.find(params[:id])
    # 修正: @stay が current_user のものか確認する (scaffold で抜けていることが多い)
    head :forbidden unless @stay.owner_id == current_user.id
  end
  
  # --- 以下の stay_params を追加 ---
  def stay_params
    # pet_id や sitter_id も必要に応じて permit に追加してください
    params.require(:stay).permit(
      :pet_id,
      :sitter_id,
      :place,
      :start_on,
      :end_on,
      :status,
      :notes
      # :parent_stay_id は直接フォームから受け取らない
    )
  end
end