class HandoffsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_handoff, only: [:edit, :update, :complete]

  # 引継ぎリストの一覧を表示
  def index
    # 本来は「自分の関わっている引継ぎ」だけを表示すべきですが、
    # まずは全件表示して動作確認できるようにします
    @handoffs = Handoff.order(scheduled_at: :desc)
  end

  # 引継ぎリストの編集画面
  def edit
  end

  # 更新処理
  def update
    if @handoff.update(handoff_params)
      redirect_to handoffs_path, notice: '引継ぎリストを更新しました！'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # 「完了」ボタンを押したときの処理
  def complete
    # 完了日時(completed_at)に現在時刻を入れて保存
    @handoff.update(completed_at: Time.current)
    redirect_to handoffs_path, notice: '引継ぎを完了にしました！✅'
  end

  private

  def set_handoff
    @handoff = Handoff.find(params[:id])
  end

  def handoff_params
    # チェックリスト(checklist)と、予定日(scheduled_at)を許可
    params.require(:handoff).permit(:checklist, :scheduled_at)
  end
end