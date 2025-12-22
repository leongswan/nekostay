Rails.application.routes.draw do
  # 削除：get 'reviews/new'
  # 削除：get 'reviews/create'

  # トップページをダッシュボードに設定
  root 'stays#index'
  
  devise_for :users

  resources :stays do
    member do
      delete :delete_image
    end
    
    resources :checkins

    # ↓↓↓ ★★★ ここに追加します！（staysの中に書くのがポイント） ★★★
    resources :reviews, only: [:new, :create, :destroy]
    # -------------------------------------------------------------

    # 契約書のダウンロード用URL
    resource :contract, only: [:show]

    # 決済機能
    resources :payments, only: [:create] do
      get 'success', on: :collection
    end
  end

  resources :messages, only: [:create]

  resources :pets

  resources :handoffs, only: [:index, :edit, :update] do
    member do
      patch :complete
    end
  end
end