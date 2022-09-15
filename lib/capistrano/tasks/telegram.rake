namespace :telegram do
  desc "set webhooks on Telegram bot"
  task :set_webhook do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, "telegram:bot:set_webhook"
        end
      end 
    end
  end
end
