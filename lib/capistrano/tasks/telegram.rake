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

  task :announce_commit do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, "telegram:announce_commit"
      end
    end
  end
end
