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
end
