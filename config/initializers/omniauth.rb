Rails.application.config.middleware.use OmniAuth::Builder do
  provider :telegram, Rails.application.credentials.telegram.bot.username, Rails.application.credentials.telegram.bot.token
  provider :steam, Rails.application.credentials.steam.token
end

# When a user uses the /login link without checking the box to provide their
# data, authentication will fail. In this case, we want them to be gracefully
# redirected to the home page to log in manually instead.
OmniAuth.config.on_failure = Proc.new { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}
