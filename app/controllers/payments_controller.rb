class PaymentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_stay

  def create
    # Stripeの支払いセッションを作成
    session = Stripe::Checkout::Session.create(
      payment_method_types: ['card'],
      line_items: [{
        price_data: {
          currency: 'jpy',
          product_data: {
            name: "ペットシッター料金 (#{@stay.pet&.name})",
            description: "期間: #{@stay.start_on} 〜 #{@stay.end_on}",
          },
          unit_amount: 5000, # テスト用金額 (5000円)
        },
        quantity: 1,
      }],
      mode: 'payment',
      # --- 修正: 戻り先を専用アクションに変更 ---
      success_url: success_stay_payments_url(@stay),
      # --------------------------------------
      # キャンセル時の戻り先
      cancel_url: stay_url(@stay, payment: 'cancel'),
    )

    # Stripeの支払い画面へリダイレクト (See Other 303)
    redirect_to session.url, allow_other_host: true, status: :see_other
  end

  # --- 追加: 支払い成功時の処理 ---
  def success
    # 本来はStripeのWebhookで安全に処理しますが、
    # 今回は簡易的に「ここに戻ってきたら支払い完了」として扱います。
    
    # 支払い日時を記録 (すでに支払済みの場合は更新しない)
    @stay.update(paid_at: Time.current) unless @stay.paid_at?
    
    redirect_to stay_path(@stay), notice: "お支払いが完了しました！ありがとうございます。"
  end
  # -----------------------------

  private

  def set_stay
    @stay = Stay.find(params[:stay_id])
  end
end
