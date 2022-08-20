Rails.application.routes.draw do
  get 'pages/home'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  
  root "pages#home"
  telegram_webhook TelegramWebhooksRouter
  
  # OmniAuth endpoints, Steam POSTs back instead of GET
  get    'auth/telegram/callback', to: 'sessions#telegram'
  post   'auth/steam/callback',    to: 'sessions#steam'
  delete 'logout',                 to: 'sessions#destroy'
end
