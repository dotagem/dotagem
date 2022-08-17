Rails.application.config.middleware.use OmniAuth::Builder do
  provider :telegram, Rails.application.credentials.telegram.bot.username, Rails.application.credentials.telegram.bot.token
  provider :steam, Rails.application.credentials.steam.token
end
