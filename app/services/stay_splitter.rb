class StaySplitter
  def initialize(stay)
    @stay = stay
  end

  # 分割して保存
  def save_splits!(destroy_original: false, create_handoffs: true)
    # すでに子が存在する場合 → いったん削除
    @stay.children.destroy_all if @stay.children.exists?

    # 分割結果を作成
    slices = split
    children = []

   ActiveRecord::Base.transaction do
    slices.each do |range|
      children << @stay.children.create!(
        pet:        @stay.pet,
        owner:      @stay.owner,
        sitter:     @stay.sitter,
        place:      @stay.place,
        status:     @stay.status,
        start_on:   range.first,
        end_on:     range.last,
        notes:      @stay.notes
      )
    end

    if create_handoffs
        children.each_cons(2) do |a, b|
          Handoff.create!(
            from_stay:   a,
            to_stay:     b,
            checklist:   default_checklist_for(a, b),
            # 例：前のステイが終わる日の 18:00 に引継ぎ
            scheduled_at: (a.end_on.in_time_zone + 18.hours).to_time
          )
        end
      end

    # 元の Stay を削除するか残すか
    @stay.destroy if destroy_original
  end

     children
end

  # 14日ごとに分割
  def split
    ranges = []
    current_start = @stay.start_on

    while current_start <= @stay.end_on
      e = [current_start + 13, @stay.end_on].min
      ranges << (current..e)
      current = e + 1
    end

    ranges
  end

  private

  def default_checklist_for(a, b)
    <<~TXT.strip
      - 餌・水の残量確認
      - トイレ清掃状況
      - 投薬（必要な場合）情報と時刻
      - 体重・食欲・排泄のメモ
      - 予備の砂/フードの置き場所
      - 緊急連絡先・かかりつけ医
    TXT
  end
end