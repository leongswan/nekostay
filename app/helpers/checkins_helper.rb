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
    md = meds_or_checkin.is_a?(Hash) ? meds_or_checkin || {} : meds_or_checkin.meds || {}
    return "-" if md.blank?

    pills = []
    pills << pill("投与なし", :cancelled) if md["none"]
    pills << pill("投与済",   :active)    if md["given"]
    pills << pill("ワクチン3回目済", :active) if md["vaccine_3rd"]

    if md["name"].present? || md["dose"].present?
      pills << pill([md["name"], md["dose"]].compact.join(" / "))
    end

    return "-" if pills.empty?
    safe_join(pills, " ")
  end

  # --- 従来の文字ラベル版（バックエンドやCSV向けなどに使用） ---
  def meds_label(meds)
    md = meds || {}
    parts = []
    parts << "投与なし" if md["none"]
    parts << "投与済" if md["given"]
    parts << "ワクチン3回目済" if md["vaccine_3rd"]
    parts << "薬剤: #{md['name']}" if md['name'].present?
    parts << "投与量: #{md['dose']}" if md['dose'].present?
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
