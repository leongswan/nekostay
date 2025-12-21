Rails.application.routes.draw do
  # トップページをダッシュボードに設定
  root 'stays#index'
  
  # 以前のトップページ（将来のために残しておく）
  # root 'static_pages#home'

  devise_for :users

  resources :stays do
    member do
      delete :delete_image
    end
    
    resources :checkins

    # 契約書のダウンロード用URL
    resource :contract, only: [:show]

    # 決済機能
    resources :payments, only: [:create] do
      get 'success', on: :collection
    end
  end

  # ★★★ 修正ポイント：ここに置くのが正解です！（staysの外） ★★★
  resources :messages, only: [:create]
  # -------------------------------------------------------

  resources :pets

  resources :handoffs, only: [:index, :edit, :update] do
    member do
      patch :complete
    end
  end
end
