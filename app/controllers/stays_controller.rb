# --- 修正：キャッシュを回避するため、ファイルを直接読み込む ---
require_relative '../../lib/services/stay_splitter'
# --- 修正ここまで ---

class StaysController < ApplicationController
  before_action :authenticate_user!
  before_action :set_stay, only: %i[show edit update destroy] 

  def index
    @stays = Stay.where(owner_id: current_user.id).order(start_on: :desc)
  end

  def show
    @recent_checkins = @stay.checkins.order(checked_at: :desc).limit(3)
  end

  def new
    @stay = Stay.new
    @pets = current_user.pets.order(:name)
  end

  # --- 修正：StaySplitter::MAX_DAYS エラーを回避 ---
  def create
    @stay = current_user.owned_stays.new(stay_params)
    
    if @stay.save
      # StaySplitter.split! を無条件で呼び出す
      # (分割が必要かは StaySplitter 内部が判断する)
      StaySplitter.split!(@stay)
      
      redirect_to stay_path(@stay), notice: "滞在を登録しました。", status: :see_other
    else
      @pets = current_user.pets.order(:name) 
      flash.now[:alert] = "保存に失敗しました。入力内容をご確認ください。"
      render :new, status: :unprocessable_entity
    end
  end
  # --- 修正ここまで ---

  def edit
    # @stay は set_stay が実行
  end

  def update
    if @stay.update(stay_params)
      # (TODO: update 時も StaySplitter を呼び出すか検討)
      redirect_to stay_path(@stay), notice: "滞在を更新しました。", status: :see_other
    else
      flash.now[:alert] = "更新に失敗しました。入力内容をご確認ください。"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @stay.destroy
    redirect_to stays_path, notice: "滞在を削除しました。", status: :see_other
  end

  private

  def set_stay
    @stay = Stay.find(params[:id])
    head :forbidden unless @stay.owner_id == current_user.id
  end
  
  def stay_params
    params.require(:stay).permit(
      :pet_id,
      :sitter_id,
      :place,
      :start_on,
      :end_on,
      :status,
      :notes
    )
  end
end