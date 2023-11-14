Rails.application.config.middleware.use OmniAuth::Builder do
  unless ENV["PRECOMPILE_ASSETS_SKIP"]
    provider :telegram, ENV.fetch("TELEGRAM_BOT_USERNAME"), ENV.fetch("TELEGRAM_BOT_TOKEN")
    provider :steam, ENV.fetch("STEAM_TOKEN")
  end
end

# When a user uses the /login link without checking the box to provide their
# data, authentication will fail. In this case, we want them to be gracefully
# redirected to the home page to log in manually instead.
OmniAuth.config.on_failure = Proc.new { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}
