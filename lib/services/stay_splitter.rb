require 'date'

class StaySplitter
  
  MAX_DAYS = 14

  def self.split!(parent_stay)
    return if parent_stay.children.exists?

    duration = (parent_stay.end_on - parent_stay.start_on).to_i + 1
    return if duration <= MAX_DAYS

    current_start = parent_stay.start_on
    
    # --- 修正：前のループ（子ステイ）を保持する変数を追加 ---
    previous_child_stay = nil
    
    while current_start <= parent_stay.end_on
      segment_end = [current_start + (MAX_DAYS - 1), parent_stay.end_on].min

      child = parent_stay.children.create!(
        pet:      parent_stay.pet,
        owner:    parent_stay.owner,
        sitter:   parent_stay.sitter,
        place:    parent_stay.place,
        start_on: current_start,
        end_on:   segment_end,
        status:   "draft"
      )
      
      # --- 💡 Handoffロジックの組み込み 💡 ---
      #
      # 2ループ目以降（previous_child_stay が存在する）の場合
      if previous_child_stay
        # 前の子ステイ (from) から、今作った子ステイ (to) への
        # Handoff (引継ぎ) レコードを自動作成する
        Handoff.create!(
          from_stay: previous_child_stay,
          to_stay:   child,
          # scheduled_at は、間の日（例: 11/14 の夜）などを設定
          scheduled_at: previous_child_stay.end_on.end_of_day
        )
      end
      # --- 組み込みここまで ---

      # 次のループのために、今作った子ステイを「前の子ステイ」として保持
      previous_child_stay = child
      
      current_start = segment_end + 1
    end
    
    true
  end
end