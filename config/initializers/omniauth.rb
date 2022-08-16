Rails.application.config.middleware.use OmniAuth::Builder do
  provider :telegram, Rails.application.credentials.telegram.bot.username, Rails.application.credentials.telegram.bot.token
  provider :steam, Rails.application.credentials.steam.token
end

# Allow get because it doesn't matter for us
OmniAuth.config.allowed_request_methods = [:get, :post]
OmniAuth.config.silence_get_warning = true
