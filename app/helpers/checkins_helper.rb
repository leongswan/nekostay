module CheckinsHelper
  def dt_label(dt)
    dt.present? ? dt.strftime("%Y-%m-%d %H:%M") : "-"
  end

  def weight_label(kg)
    kg.present? ? "#{kg} kg" : "-"
  end

  def meal_label(meal)
    m = meal || {}
    return "-" if m.blank?
    [m["brand"], m["amount"]].compact.join(" / ").presence || "-"
  end

  def litter_label(litter)
    l = litter || {}
    return "-" if l.blank?
    parts = []
    parts << "固まり: #{l['clumps']}" if l['clumps'].present?
    parts << "おしっこ: #{l['pee']}"  if l['pee'].present?
    parts.presence ? parts.join(" / ") : "-"
  end

  # --- 追加：Meds を“ピル表示”で整形 ---
  def meds_badges(meds_or_checkin)
    return "" if meds_or_checkin.nil?
    med = meds_or_checkin.is_a?(Hash) ? meds_or_checkin : (meds_or_checkin.meds || {})

    pills = []
    pills << pill("投与なし", :cancelled) if med["none"]
    pills << pill("投与済",   :active)    if med["given"]
    pills << pill("ワクチン3回目済", :active) if med["vaccine_3rd"]

    if med["name"].present? || med["dose"].present?
      pills << pill([med["name"], med["dose"]].compact.join(" / "))
    end

    return "-" if pills.empty?
    safe_join(pills, " ")
  end

  # --- 従来の文字ラベル版（バックエンドやCSV向けなどに使用） ---
  def meds_label(meds)
    med = meds || {}
    parts = []
    parts << "投与なし" if med["none"]
    parts << "投与済" if med["given"]
    parts << "ワクチン3回目済" if med["vaccine_3rd"]
    parts << "薬剤: #{med['name']}" if med['name'].present?
    parts << "投与量: #{med['dose']}" if med['dose'].present?
    parts.present? ? parts.join(" / ") : "-"
  end

  private

  # 見た目用の汎用 pill
  def pill(text, kind = nil)
    klass = ["pill"]
    klass << "pill--#{kind}" if kind.present?
    content_tag(:span, text, class: klass.join(" "))
  end
end
