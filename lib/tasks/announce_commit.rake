namespace :telegram do
  desc "Sends the contents of CHANGELOG into the designated channel."

  task :announce_commit do
    if ENV["TELEGRAM_BOT_CHANNEL"]
      if File.exists?("#{Rails.root}/CHANGELOG") && !(File.read("#{Rails.root}/CHANGELOG").empty?)
        Telegram.bot.send_message(
          chat_id: ENV["TELEGRAM_BOT_CHANNEL"],
          disable_web_page_preview: true,
          text: File.read("#{Rails.root}/CHANGELOG"),
          parse_mode: "html"
        )
        puts("Posted the changelog message!")
      else
        puts("No CHANGELOG file provided or file was empty, doing nothing.")
      end
    else
      puts "No changelog channel has been defined in the credentials, doing nothing."
    end
  end
end
