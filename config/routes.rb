Rails.application.routes.draw do
  get 'pages/home'
  get 'sessions/telegram'
  get 'sessions/steam'
  get 'sessions/destroy'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  
  root "pages#home"
  telegram_webhook TelegramWebhooksController
  
  # OmniAuth endpoints, Steam posts back instead of getting
  get  'auth/telegram/callback', to: 'sessions#telegram'
  post 'auth/steam/callback',    to: 'sessions#steam'
end
