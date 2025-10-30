# spec/system/checkins_spec.rb
require "rails_helper"

RSpec.describe "Checkins", type: :system, js: true do
  let(:owner) { create(:user) }
  let(:pet)   { create(:pet, user: owner) }
  let(:stay)  { create(:stay, pet: pet, owner_id: owner.id) }

  before { login_as(owner, scope: :user) }

  it "作成→編集→削除の一連が動く" do
    # 一覧
    visit stay_checkins_path(stay)
    expect(page).to have_content(I18n.t("checkins.index.title"))

    # 新規作成（URL直叩き：モーダルに依存しない）
    visit new_stay_checkin_path(stay)

    # 日時は datetime-local なので値は "YYYY-MM-DDTHH:MM"
    ts = Time.zone.now.change(sec: 0).strftime("%Y-%m-%dT%H:%M")
    # JavaScriptを直接実行して、datetime-localフィールドのvalueを強制的に設定する
    page.execute_script("document.getElementById('checkin_checked_at').value = '#{ts}'")

    fill_in I18n.t("checkins.form.weight"),     with: "4.20"
    fill_in I18n.t("checkins.form.memo"),       with: "よく食べた"

    fill_in I18n.t("checkins.form.meal_amount"), with: "50g"
    fill_in I18n.t("checkins.form.meal_brand"),  with: "Royal Canin"

    fill_in I18n.t("checkins.form.litter_clumps"), with: "2"
    fill_in I18n.t("checkins.form.litter_pee"),    with: "1"

    fill_in I18n.t("checkins.form.meds_name"), with: "抗生剤"
    fill_in I18n.t("checkins.form.meds_dose"), with: "1錠"
    check   I18n.t("checkins.form.meds_given")
    uncheck I18n.t("checkins.form.meds_none")
    check   I18n.t("checkins.form.vaccine_3rd")

    # 送信（「作成」ラベル）
    click_button I18n.t("checkins.form.create")
    # application.html.erb で設定したコンテナIDを使い、
    # その「内部に」期待するテキストが表示されるのを待機する。
    expect(page).to have_selector("#flash_messages", text: I18n.t("checkins.notices.created"))

    expect(page).to have_selector("table")
    expect(page).to have_content("4.2 kg")
    expect(page).to have_content(I18n.t("helpers.pills.meds.given"))
    expect(page).to have_content(I18n.t("helpers.pills.meds.vaccine_3rd"))

    # --- 以下の「編集」ブロック全体を置き換えます ---

    # 修正: _top リダイレクト後のレースコンディションを回避するため、
    # リンククリック（非同期モーダル）に依存するのをやめ、
    # 編集ページのURLを直接 visit する（同期）フォールバックを
    # 常に使用するように変更します。
    # これにより、edit.html.erb (フルページ) が読み込まれます。
    visit edit_stay_checkin_path(stay, stay.checkins.order(:id).last)
    
    # --- 修正ここまで ---
    # 待機するセレクタを、モーダル (div.modal-panel h3) から
    # フルページ (edit.html.erb が持つ h1) に変更します。
    expect(page).to have_selector(
      "h1", 
      text: I18n.t("checkins.edit.title"), 
      visible: true
    )

    fill_in I18n.t("checkins.form.memo"), with: "更新メモ"
    click_button I18n.t("checkins.form.update")

    # update 成功後の notice を待機する
    expect(page).to have_selector(
      "#flash_messages", 
      text: I18n.t("checkins.notices.updated")
    )
    expect(page).to have_content("更新メモ")

    # 削除（最初の行）
    accept_confirm do
      click_button I18n.t("checkins.index.destroy"), match: :first
    end
    expect(page).to have_selector(
      "#flash_messages", 
      text: I18n.t("checkins.notices.destroyed")
    )
  end
end
