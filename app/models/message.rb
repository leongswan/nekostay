class Message < ApplicationRecord
  belongs_to :stay
  belongs_to :user

  # ↓↓↓ これを追加（空のメッセージは禁止）
  validates :body, presence: true

  # ★★★ ここが魔法の呪文です ★★★
  # メッセージが作成(create)されたら、
  # 紐づいている予約(@stay)のチャネルに向かって、
  # "messages" というIDの場所に、自分自身(_message.html.erb)を追加(append)して放送する
  after_create_commit -> { broadcast_append_to stay, target: "messages" }
end
