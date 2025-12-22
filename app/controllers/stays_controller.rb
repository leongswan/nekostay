# --- 修正：キャッシュを回避するため、ファイルを直接読み込む ---
# --- 修正ここまで ---

class StaysController < ApplicationController
  before_action :authenticate_user!
  before_action :set_stay, only: %i[show edit update destroy delete_image] 

  def index
    @stays = Stay.where(owner_id: current_user.id).order(start_on: :desc)

    # ↓↓↓ この行を追加（自分がシッターとして指名されている予約を取得） ↓↓↓
    @assigned_stays = Stay.where(sitter_id: current_user.id).order(start_on: :asc)
    # ---------------------------------------------------------------
  end

  def show
    @recent_checkins = @stay.checkins.order(checked_at: :desc).limit(3)
  end

  def new
    @stay = Stay.new
    @pets = current_user.pets.order(:name)
  end

  def create
    # current_user.stays.build で owner_id は自動セットされます
    @stay = current_user.stays.build(stay_params)
    
    # この1行が絶対に必要です！
    @stay.user_id = current_user.id
    
    if @stay.save
      # ↓↓↓ ★★★ 追加：引継ぎリストを自動作成する ★★★ ↓↓↓
      Handoff.create!(
        from_stay: @stay,
        to_stay: @stay,
        # 引継ぎ時間は、予約開始日の「朝9時」に自動設定
        scheduled_at: @stay.start_on.in_time_zone.change(hour: 9, min: 0)
      )
      # ----------------------------------------------------
      
      # StaySplitter.split! を無条件で呼び出す
      StaySplitter.split!(@stay)
      
      redirect_to stay_path(@stay), notice: "滞在を登録しました。引継ぎリストも作成されました！", status: :see_other
    else
      @pets = current_user.pets.order(:name) 
      flash.now[:alert] = "保存に失敗しました。入力内容をご確認ください。"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    # 編集画面のドロップダウン用に、ペット一覧を取得します
    @pets = current_user.pets.order(:name)
  end

  def update
    # 1. データ更新を試みる
    if @stay.update(stay_params)
      
      # ★重要: 日付が変わった場合、スケジュール(Checkin)を作り直す機能
      StaySplitter.split!(@stay)

      # 成功時の処理
      respond_to do |format|
        format.html { redirect_to stay_path(@stay), notice: "予約内容を更新しました！", status: :see_other }
        format.json { render :show, status: :ok, location: @stay }
      end

    else
      # ★重要: エラー時にペットの選択肢を再読み込みする（これがないとクラッシュします）
      @pets = current_user.pets.order(:name)
      
      # 失敗時の処理
      respond_to do |format|
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
    # 修正：飼い主(owner) または シッター(sitter) ならアクセスOKにする
    unless @stay.owner_id == current_user.id || @stay.sitter_id == current_user.id
      head :forbidden
    end
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