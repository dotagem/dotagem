Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  
  root "pages#home"

  get "commands", to: "pages#commands"
  get "help",     to: "pages#help"

  resources :users, only: [:destroy]
  delete "users/:id/unlink", to: "users#unlink_steam", as: "user_unlink_steam"

  telegram_webhook TelegramWebhooksRouter
  
  # OmniAuth endpoints, Steam POSTs back instead of GET
  get    'auth/telegram/callback', to: 'sessions#telegram'
  post   'auth/steam/callback',    to: 'sessions#steam'
  get    'auth/failure',           to: 'sessions#failure'
  delete 'logout',                 to: 'sessions#destroy'
end
