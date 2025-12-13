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
      # 支払い成功時の戻り先 (チャット画面などに戻すのが一般的)
      success_url: stay_url(@stay) + '?payment=success',
      # キャンセル時の戻り先
      cancel_url: stay_url(@stay) + '?payment=cancel',
    )

    # Stripeの支払い画面へリダイレクト (See Other 303)
    redirect_to session.url, allow_other_host: true, status: :see_other
  end

  private

  def set_stay
    @stay = Stay.find(params[:stay_id])
  end
end
