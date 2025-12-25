class MessagesController < ApplicationController
  before_action :authenticate_user!

  def create
    @stay = Stay.find(params[:message][:stay_id])
    @message = @stay.messages.new(message_params)
    @message.user = current_user

    # ★★★ ここを追加：受信者を自動設定する ★★★
    # もし自分が飼い主なら、相手はシッター。自分がシッターなら、相手は飼い主。
    if current_user.id == @stay.owner_id
      @message.receiver_id = @stay.sitter_id
    else
      @message.receiver_id = @stay.owner_id
    end
    # ------------------------------------------

    if @message.save
      # 成功時の処理（Turbo Streamで画面更新）
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to stay_path(@stay) }
      end
    else
      # 失敗時の処理
      redirect_to stay_path(@stay), alert: "メッセージの送信に失敗しました。"
    end
  end

  private

  def message_params
    params.require(:message).permit(:body, :stay_id)
  end
end