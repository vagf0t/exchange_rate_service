
Rails.application.routes.draw do
  resources :exchange_rates, param: :on, only: [:show] do
    get :show, on: :collection
  end

  get 'us_dollars_to_euros/:on/:amount' => 'us_dollars_to_euros#show'
end