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

    # 修正: レースコンディション対策
    # Capybara の .click は Turbo の JS イベントより先に実行され
    # "デッド・クリック" になることがある。
    
    # 1. まず Capybara の waiter (find) でリンク要素を見つける
    edit_link = find("a[data-turbo-frame='modal']", 
                     text: I18n.t("checkins.index.edit"), 
                     match: :first)
    
    # 2. Capybara の .click ではなく、
    #    execute_script でブラウザに直接 JS でクリックさせる
    page.execute_script("arguments[0].click();", edit_link)

    # --- 修正ここまで ---

    # --- 以下の1行を追加 ---
    # 
    # 修正: レースコンディション対策
    # "編集" をクリックするとモーダルが非同期で読み込まれるため、
    # 編集フォームのタイトルが表示されるまで Capybara に待機させる
    expect(page).to have_content(I18n.t("checkins.edit.title"))
    # --- 修正ここまで ---

    fill_in I18n.t("checkins.form.memo"), with: "更新メモ"
    click_button I18n.t("checkins.form.update")

    expect(page).to have_content(I18n.t("checkins.notices.updated"))
    expect(page).to have_content("更新メモ")

    # 削除（最初の行）
    accept_confirm do
      click_button I18n.t("checkins.index.destroy"), match: :first
    end
    expect(page).to have_content(I18n.t("checkins.notices.destroyed"))
  end
end
