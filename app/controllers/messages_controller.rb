class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_stay

  # GET /stays/:stay_id/messages
  def index
    # 新しい順ではなく、チャットのように「古い順」で表示するのが一般的
    @messages = @stay.messages.order(created_at: :asc)
    @message = Message.new
  end

  # POST /stays/:stay_id/messages
  def create
    @message = @stay.messages.new(message_params)
    @message.sender = current_user

    # 受信者 (Receiver) の自動判定
    # 自分がオーナーなら -> 相手はシッター
    # 自分がシッターなら -> 相手はオーナー
    if @stay.owner_id == current_user.id
      @message.receiver_id = @stay.sitter_id
    else
      @message.receiver_id = @stay.owner_id
    end

    if @message.save
      # 送信成功したら、チャット画面にリダイレクト
      redirect_to stay_messages_path(@stay), notice: "メッセージを送信しました。"
    else
      @messages = @stay.messages.order(created_at: :asc)
      flash.now[:alert] = "メッセージの送信に失敗しました。"
      render :index, status: :unprocessable_entity
    end
  end

  private

  def set_stay
    @stay = Stay.find(params[:stay_id])
    
    # 権限チェック: 関係ないユーザーはアクセス禁止
    unless @stay.owner_id == current_user.id || @stay.sitter_id == current_user.id
      redirect_to root_path, alert: "権限がありません。"
    end
  end

  def message_params
    params.require(:message).permit(:body)
  end
end