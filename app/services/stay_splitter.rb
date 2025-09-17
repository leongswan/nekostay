class StaySplitter
  def initialize(stay)
    @stay = stay
  end

  # 分割して保存
  def save_splits!(destroy_original: false)
    # すでに子が存在する場合 → いったん削除
    @stay.children.destroy_all if @stay.children.exists?

    # 分割結果を作成
    slices = split

    slices.each do |range|
      @stay.children.create!(
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

    # 元の Stay を削除するか残すか
    @stay.destroy if destroy_original
  end

  # 14日ごとに分割
  def split
    ranges = []
    current_start = @stay.start_on

    while current_start <= @stay.end_on
      current_end = [current_start + 13, @stay.end_on].min
      ranges << (current_start..current_end)
      current_start = current_end + 1
    end

    ranges
  end
end