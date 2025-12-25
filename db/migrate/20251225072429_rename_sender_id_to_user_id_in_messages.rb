class RenameSenderIdToUserIdInMessages < ActiveRecord::Migration[7.1]
  def change
    # もし user_id が既に存在し、かつ sender_id も存在する場合
    if column_exists?(:messages, :user_id) && column_exists?(:messages, :sender_id)
      # 古い sender_id を削除する（データ移行が必要な場合は別途スクリプトが必要ですが、今回は開発段階なので削除で対応）
      remove_column :messages, :sender_id
    
    # user_id はないけど sender_id はある場合（通常のリネーム）
    elsif !column_exists?(:messages, :user_id) && column_exists?(:messages, :sender_id)
      rename_column :messages, :sender_id, :user_id
    end
  end
end
