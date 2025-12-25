class RenameSenderIdToUserIdInMessages < ActiveRecord::Migration[7.1]
  def change
    # もし sender_id というカラムがあれば、user_id に名前を変更する
    if column_exists?(:messages, :sender_id)
      rename_column :messages, :sender_id, :user_id
    end
    
    # ※もし既に user_id がある場合は何もしない
  end
end
