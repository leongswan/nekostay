class PaymentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_stay

  def create
    # 1. 値段を決める（今回はテスト用に一律 3,000円 とします）
    # ※ 本格的にするなら Stay モデルに price カラムを追加して保存します
    amount = 3000 

    # 2. Stripeの支払い画面（セッション）を作成する
    session = Stripe::Checkout::Session.create(
      payment_method_types: ['card'],
      line_items: [{
        price_data: {
          currency: 'jpy', # 日本円
          product_data: {
            name: "#{@stay.pet.name}ちゃんのシッター代金",
          },
          unit_amount: amount,
        },
        quantity: 1,
      }],
      mode: 'payment',
      # 支払いが成功したら戻ってくるURL
      success_url: success_stay_payments_url(@stay),
      # キャンセルした場合に戻ってくるURL
      cancel_url: stay_url(@stay),
    )

    # 3. Stripeの画面へ移動させる
    redirect_to session.url, allow_other_host: true
  end

  def success
    # ★★★ 修正：「true」ではなく「現在時刻」を保存します ★★★
    @stay.update(paid_at: Time.current)
    # ----------------------------------------------------
    
    redirect_to stay_path(@stay), notice: 'お支払いが完了しました！ありがとうございます！🎉'
  end

  private

  def set_stay
    @stay = Stay.find(params[:stay_id])
  end
end