# --- 修正：キャッシュを回避するため、ファイルを直接読み込む ---
require_relative '../../lib/services/stay_splitter'
# --- 修正ここまで ---

class StaysController < ApplicationController
  before_action :authenticate_user!
  before_action :set_stay, only: %i[show edit update destroy delete_image] 

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
    respond_to do |format|
      # 1. まず、画像「以外」のデータ（メモなど）を更新します
      #    (画像データをここで渡すと上書きされてしまうため、exceptで除外します)
      if @stay.update(stay_params.except(:report_images))
        
        # 2. もし新しい画像が送られてきていたら、既存リストに「追加 (attach)」します
        if stay_params[:report_images].present?
          @stay.report_images.attach(stay_params[:report_images])
        end

        format.html { redirect_to stay_url(@stay), notice: "滞在情報を更新しました！" }
        format.json { render :show, status: :ok, location: @stay }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @stay.errors, status: :unprocessable_entity }
      end
    end
  end

  # 画像削除用のアクション
  def delete_image
    # 1. 削除したい画像をIDで探す
    image = @stay.report_images.find(params[:image_id])
    
    # 2. 画像を完全に削除 (purge) する
    image.purge
    
    # 3. 元の画面に戻る
    redirect_to stay_path(@stay), notice: "写真を削除しました🗑️"
  rescue ActiveRecord::RecordNotFound
    redirect_to stay_path(@stay), alert: "写真が見つかりませんでした"
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
      :notes,
      report_images: []
    )
  end
end