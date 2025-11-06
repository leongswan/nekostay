# app/controllers/handoffs_controller.rb
class HandoffsController < ApplicationController
  before_action :authenticate_user!
  
  # 修正: set_handoff を before_action に定義
  before_action :set_handoff, only: %i[edit update complete] 
  
  # 修正: 権限チェック (Authorization) を private メソッドに共通化
  before_action :authorize_owner!, only: %i[edit update complete]

  # ----------------------------------------------------
  # GET /handoffs (ご提示いただいたコード)
  # ----------------------------------------------------
  def index
    # (Handoff モデルに .for_owner(user) スコープの実装が必要です)
    @handoffs = Handoff.for_owner(current_user).order(:scheduled_at)
  end

  # ----------------------------------------------------
  # GET /handoffs/:id/edit (チェックリスト編集画面)
  # ----------------------------------------------------
  def edit
    # @handoff は set_handoff と authorize_owner! で設定・検証済み
  end

  # ----------------------------------------------------
  # PATCH /handoffs/:id (チェックリスト更新処理)
  # ----------------------------------------------------
  def update
    # @handoff は set_handoff と authorize_owner! で設定・検証済み
    
    if @handoff.update(handoff_params)
      # 修正: 滞在詳細ではなく、Handoff一覧 に戻る
      redirect_to handoffs_path, notice: "引継ぎメモを更新しました。", status: :see_other
    else
      flash.now[:alert] = "更新に失敗しました。"
      render :edit, status: :unprocessable_entity
    end
  end

  # ----------------------------------------------------
  # PATCH /handoffs/:id/complete (ご提示いただいたコードの修正版)
  # ----------------------------------------------------
  def complete
    # @handoff は set_handoff と authorize_owner! で設定・検証済み
    
    # 修正: .complete! メソッドの代わりに completed_at を直接更新する
    if @handoff.update(completed_at: Time.current)
      redirect_to handoffs_path, notice: "引き継ぎを完了にしました。"
    else
      redirect_to handoffs_path, alert: "完了処理に失敗しました。"
    end
  end

  private

  def set_handoff
    @handoff = Handoff.find(params[:id])
  end
  
  # ----------------------------------------------------
  # 🔹 権限チェック (共通化)
  # ----------------------------------------------------
  def authorize_owner!
    # ログイン中のユーザーが、引継ぎ元(from)の
    # ステイの飼い主(owner)でなければ、編集・完了させない
    unless @handoff.from_stay.owner_id == current_user.id
      head :forbidden
    end
  end

  # ----------------------------------------------------
  # 🔹 Strong Parameters (update アクションに必須)
  # ----------------------------------------------------
  def handoff_params
    # checklist (メモ) と completed_at (完了日時) の更新を許可
    params.require(:handoff).permit(:checklist, :completed_at)
  end
end
