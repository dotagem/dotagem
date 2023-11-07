Sentry.init do |config|
  config.dsn = 'https://d67a97368f8fffbd1246c0a89b86d18c@o4505913692389376.ingest.sentry.io/4505913697042432'
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]

  # Set traces_sample_rate to 1.0 to capture 100%
  # of transactions for performance monitoring.
  # We recommend adjusting this value in production.
  config.traces_sample_rate = 1.0
end

module Telegram::Bot
  class UnknownCommand < StandardError; end
end
