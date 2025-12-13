# config/routes.rb
Rails.application.routes.draw do
  devise_for :users

  # --- 修正 ---
  #
  # :only を削除し、Stays の標準的なルーティング
  # (index, show, new, create, edit, update, destroy) を
  # すべて許可します。
  #
  resources :stays do
  #
  # --- 修正ここまで ---
    resources :checkins

  # --- 追加: メッセージのルーティング (一覧と作成のみ) ---
    resources :messages, only: [:index, :create]
  # --- 追加ここまで ---
  end



  # --- Handoffs の修正 ---
  
  # 修正: :index に加えて :edit, :update を許可
  resources :handoffs, only: [:index, :edit, :update] do
    member do
      # 修正: 'GET' (データを取得) ではなく 'PATCH' (データを更新) に変更
      patch :complete
    end
  end
  # --- 修正ここまで ---

  root "stays#index"
end
