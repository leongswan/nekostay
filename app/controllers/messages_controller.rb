class MessagesController < ApplicationController
  before_action :authenticate_user!

  def create
    # 1. どの予約(Stay)に対するメッセージか特定する
    @stay = Stay.find(params[:message][:stay_id])

    # 2. セキュリティチェック: 飼い主かシッター以外は書き込めないようにする
    unless @stay.owner_id == current_user.id || @stay.sitter_id == current_user.id
      redirect_to root_path, alert: "権限がありません"
      return
    end

    # 3. メッセージを作成する
    @message = @stay.messages.build(message_params)
    @message.user = current_user # 「誰が書いたか」をセット

    if @message.save
      # 成功したら、元の画面（予約詳細）に戻る
      redirect_to stay_path(@stay), notice: "メッセージを送信しました 💌"
    else
      # 失敗したら（空送信など）、エラーを表示して戻る
      redirect_to stay_path(@stay), alert: "メッセージを入力してください"
    end
  end

  private

  def message_params
    params.require(:message).permit(:body, :stay_id)
  end
end