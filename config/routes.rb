Rails.application.routes.draw do
  devise_for :users

  resources :stays, only: [:index, :show] do
    resources :checkins, only: [:index, :new, :create, :show, :edit, :update, :destroy]
  end

  resources :handoffs, only: [:index] do
    member do
      get :complete
    end
  end

  root "stays#index"
end
