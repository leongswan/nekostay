# app/controllers/stays_controller.rb
class StaysController < ApplicationController
  before_action :authenticate_user!
  before_action :set_stay, only: :show

  def index
    # オーナー本人の Stay を新しい順で
    @stays = Stay.where(owner_id: current_user.id).order(start_on: :desc)
  end

  def show
    @stay = Stay.find(params[:id])
    @recent_checkins = @stay.checkins.order(checked_at: :desc).limit(3)
  end

  private

  def set_stay
    @stay = Stay.find(params[:id])
    head :forbidden unless @stay.owner_id == current_user.id
  end
end
