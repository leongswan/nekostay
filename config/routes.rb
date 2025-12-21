# config/routes.rb
Rails.application.routes.draw do
  # root 'static_pages#home'
  root 'stays#index'
  devise_for :users

  # --- 修正 ---
  #
  # :only を削除し、Stays の標準的なルーティング
  # (index, show, new, create, edit, update, destroy) を
  # すべて許可します。
  #
   resources :stays do

    # ↓ これを追加：特定の画像の削除URLを作ります
    member do
      delete :delete_image
    end
    # ----------------
  #
  # --- 修正ここまで ---
    resources :checkins

  # --- 追加: メッセージのルーティング (一覧と作成のみ) ---
    resources :messages, only: [:index, :create]
  # --- 追加ここまで ---

  # --- 追加: 契約書のダウンロード用URL ---
    # URL例: /stays/1/contract (GET)
    resource :contract, only: [:show]
  # --- 追加ここまで ---

  # --- 修正: success アクションを追加 ---
    resources :payments, only: [:create] do
      get 'success', on: :collection
     end
  # ----------------------------------

  end

  # ↓↓↓ この行を追加してください ↓↓↓
   resources :pets
  # --------------------------------



  # --- Handoffs の修正 ---
  
  # 修正: :index に加えて :edit, :update を許可
  resources :handoffs, only: [:index, :edit, :update] do
    member do
      # 修正: 'GET' (データを取得) ではなく 'PATCH' (データを更新) に変更
      patch :complete
    end
  end
  # --- 修正ここまで ---

end
