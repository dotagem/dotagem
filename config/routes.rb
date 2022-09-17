Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  
  root "pages#home"

  get "commands", to: "pages#commands"
  get "help",     to: "pages#help"
  get "faq",      to: "pages#help"
  get "admin",    to: "pages#admin"

  scope "/admin" do
    resources :heroes, only: [:index] do
      resources :nicknames, only: [:new, :create]
    end
    resources :nicknames, except: [:new, :create]
  end

  resources :users, only: [:destroy]
  delete "users/:id/unlink", to: "users#unlink_steam", as: "user_unlink_steam"

  telegram_webhook TelegramWebhooksRouter

  patch "admin/refresh_constants", to: "constants#refresh", as: "refresh_constants"
  
  # OmniAuth endpoints, Steam POSTs back instead of GET
  get    'auth/telegram/callback', to: 'sessions#telegram'
  post   'auth/steam/callback',    to: 'sessions#steam'
  get    'auth/failure',           to: 'sessions#failure'
  delete 'logout',                 to: 'sessions#destroy'
end
