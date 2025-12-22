class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_stay

  def new
    # すでにレビュー済みなら編集画面などは作らず、トップに戻す（今回はシンプルにするため）
    if @stay.review.present?
      redirect_to stay_path(@stay), alert: "すでにレビュー済みです"
    else
      @review = Review.new
    end
  end

  def create
    @review = Review.new(review_params)
    @review.stay = @stay
    
    # 評価する人＝ログインユーザー（飼い主）
    @review.rater = current_user
    
    # 評価される人＝予約の担当シッター
    @review.ratee = @stay.sitter

    if @review.save
      redirect_to stay_path(@stay), notice: 'レビューを投稿しました！ありがとうございます！⭐'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @review = @stay.review
    @review.destroy
    redirect_to stay_path(@stay), notice: 'レビューを削除しました。書き直せます！'
  end
  
  private

  def set_stay
    @stay = Stay.find(params[:stay_id])
  end

  def review_params
    params.require(:review).permit(:score, :comment)
  end
end
