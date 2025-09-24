Rails.application.routes.draw do
  devise_for :users

  resources :stays do
    resources :checkins, only: %i[index new create show destroy]
  end

  resources :handoffs, only: [:index] do
    member { get :complete }
  end

  root "stays#index"
end
