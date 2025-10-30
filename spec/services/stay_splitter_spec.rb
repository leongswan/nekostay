# spec/services/stay_splitter_spec.rb
require 'rails_helper'

# lib/ 以下の StaySplitter クラスを読み込む
require_relative '../../lib/services/stay_splitter'

RSpec.describe StaySplitter, type: :service do

  describe ".split!" do
    
    # --- 準備 (全テストで共通) ---
    let(:owner) { create(:user) }
    let(:pet)   { create(:pet, user: owner) }
    
    # let! (事前評価) を使い、各 it ブロックの *前* に Stay を1件作成する
    let!(:parent_stay) do
      create(:stay,
        owner:    owner,
        pet:      pet,
        sitter:   nil,
        place:    "owner_home",
        start_on: Date.parse("2025-11-01"),
        end_on:   Date.parse("2025-11-10") # デフォルトは10日間
      )
    end
    
    # ----------------------------------------------------
    
    context "滞在が14日以内の場合 (例: 10日間)" do
      it "子ステイもハンドオフも作成しないこと" do
        # --- 修正: not_to change 構文を削除 ---
        # 
        # 実行前の件数を確認
        expect(Stay.count).to eq(1) 
        expect(Handoff.count).to eq(0)
        
        # 実行
        StaySplitter.split!(parent_stay)
        
        # 実行後の件数も変わらないことを確認
        expect(Stay.count).to eq(1)
        expect(Handoff.count).to eq(0)
        # --- 修正ここまで ---
        
        expect(parent_stay.children.count).to eq(0)
      end
    end

    # ----------------------------------------------------

    context "滞在が14日を超える場合 (例: 30日間)" do
      
      # この context のテスト実行前に、親ステイを30日間に変更する
      before do
        parent_stay.update!(end_on: Date.parse("2025-11-30")) # 11/01〜11/30 = 30日間
      end

      it "子ステイ3件 (14, 14, 2日) と、ハンドオフ2件を正しく作成すること" do
        # 実行＆検証 ( .to change 構文は正しく動作していたので、そのまま)
        expect {
          StaySplitter.split!(parent_stay)
        }.to change(Stay, :count).by(3).and change(Handoff, :count).by(2)

        
        # --- 子ステイの日付検証 ---
        children = parent_stay.children.order(:start_on)
        expect(children.count).to eq(3)
        
        expect(children[0].start_on).to eq(Date.parse("2025-11-01"))
        expect(children[0].end_on).to eq(Date.parse("2025-11-14"))
        
        expect(children[1].start_on).to eq(Date.parse("2025-11-15"))
        expect(children[1].end_on).to eq(Date.parse("2025-11-28"))
        
        expect(children[2].start_on).to eq(Date.parse("2025-11-29"))
        expect(children[2].end_on).to eq(Date.parse("2025-11-30"))

        
        # --- Handoff の関連付けと日時の検証 ---
        handoffs = Handoff.order(:scheduled_at)
        expect(handoffs.count).to eq(2)
        
        expect(handoffs[0].from_stay).to eq(children[0])
        expect(handoffs[0].to_stay).to eq(children[1])
        expect(handoffs[0].scheduled_at).to be_within(1.second).of(children[0].end_on.end_of_day)

        expect(handoffs[1].from_stay).to eq(children[1])
        expect(handoffs[1].to_stay).to eq(children[2])
        expect(handoffs[1].scheduled_at).to be_within(1.second).of(children[1].end_on.end_of_day)
      end
      
      it "子ステイに親の情報 (pet, owner, place) が正しく引き継がれること" do
        StaySplitter.split!(parent_stay)
        
        child = parent_stay.children.first
        expect(child.pet).to eq(parent_stay.pet)
        expect(child.owner).to eq(parent_stay.owner)
        expect(child.place).to eq(parent_stay.place)
      end
    end
    
    # ----------------------------------------------------
    
    context "既に分割済み (子ステイが存在する) の場合" do
      before do
        parent_stay.update!(end_on: Date.parse("2025-11-30"))
        create(:stay, parent_stay: parent_stay, start_on: parent_stay.start_on, end_on: parent_stay.end_on)
      end
      
      it "二重に分割せず、何も作成しないこと" do
        # --- 修正: not_to change 構文を削除 ---
        #
        # 実行前の件数を確認 (親1 + 子1 = 2件)
        expect(Stay.count).to eq(2)
        expect(Handoff.count).to eq(0)

        # 実行
        StaySplitter.split!(parent_stay)

        # 実行後の件数も変わらないことを確認
        expect(Stay.count).to eq(2)
        expect(Handoff.count).to eq(0)
        # --- 修正ここまで ---
        
        expect(parent_stay.children.count).to eq(1) # 1件のまま
      end
    end

  end
end