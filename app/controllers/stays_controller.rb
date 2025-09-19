class StaysController < ApplicationController
  before_action :authenticate_user!
  before_action :set_stay, only: :show

  def index
    # まずは自分のOwnedのみ（管理者だけ全部を見る等は後で）
    @stays = current_user.owned_stays.order(start_on: :desc)
    # もしまだデータが無ければ暫定で全件を見るなら:
    # @stays = Stay.order(start_on: :desc)
  end

  def show
    # 詳細表示のみ。Checkinsへのリンクをビューで出します
  end

  private

  def set_stay
    @stay = Stay.find(params[:id])
    # オーナー本人以外は403（必要ならコメントアウト可）
    head :forbidden unless @stay.owner_id == current_user.id
  end
end
