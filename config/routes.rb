Rails.application.routes.draw do
  get 'stays/index'
  get 'checkins/index'
  get 'checkins/new'
  get 'checkins/create'
  get 'checkins/show'
  get 'handoffs/index'
  get 'handoffs/complete'

  devise_for :users
  resources :stays, only: [:index, :show] do
  resources :checkins, only: [:index, :new, :create, :show]
  end
  resources :handoffs, only: [:index] do
  member do
    get :complete
   end
 end
 root "stays#index"
end
