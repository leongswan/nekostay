class HandoffsController < ApplicationController
  before_action :authenticate_user!

  def index
    @handoffs = Handoff.for_owner(current_user).order(:scheduled_at)
  end

  def complete
    handoff = Handoff.find(params[:id])
    # 簡易な権限チェック（owner のみ）
    unless handoff.from_stay.owner_id == current_user.id
      return head :forbidden
    end
    handoff.complete!
    redirect_to handoffs_path, notice: "引き継ぎを完了にしました。"
  end
end
