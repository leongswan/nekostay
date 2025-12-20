class StaticPagesController < ApplicationController
  def home
    # もしログインしていたら、その人の予約データを取得する
    if user_signed_in?
      # 日付が近い順に並べて取得
      @my_stays = current_user.stays.order(start_on: :asc)
    end
  end
end
