Rails.application.routes.draw do
  # Deviseの設定（ユーザー管理）
  devise_for :users

  # --- トップページの切り替え設定 ---
  
  # 1. ログインしている人 → ダッシュボード (stays#index)
  authenticated :user do
    root 'stays#index', as: :authenticated_root
  end

  # 2. それ以外の人（ログインしていない人） → LP (static_pages#top)
  # ※ これがデフォルトの root_path になります
  root 'static_pages#top'
  
  # -------------------------------

  # ユーザープロフィール
  resources :users, only: [:show, :edit, :update]

  # お留守番 (Stays) 関連
  resources :stays do
    member do
      delete :delete_image
    end
    
    resources :checkins
    resources :reviews, only: [:new, :create, :destroy]
    resource :contract, only: [:show]
    resources :payments, only: [:create] do
      get 'success', on: :collection
    end
  end

  # チャットメッセージ
  resources :messages, only: [:create]

  # ペット管理
  resources :pets

  # 引継ぎリスト
  resources :handoffs, only: [:index, :edit, :update] do
    member do
      patch :complete
    end
  end
end