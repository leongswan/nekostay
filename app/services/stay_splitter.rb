class StaySplitter
  def self.split!(stay)
    # 開始日や終了日がなければ何もしない
    return unless stay.start_on && stay.end_on

    # start_on から end_on まで1日ずつループする
    (stay.start_on..stay.end_on).each do |date|
      
      # その日の Checkin がすでにあれば取得、なければ新しく作る
      # find_or_create_by を使うことで、重複作成を防ぎます
      stay.checkins.find_or_create_by(checked_at: date) do |checkin|
        
        # 新しく作る場合の設定
        # シッターが決まっていればセットするが、いなくても(nilでも)OK
        checkin.user_id = stay.sitter_id
        
        # 初期値を設定（必要なら）
        checkin.status = "pending" if checkin.respond_to?(:status)
      end
    end
  end
end