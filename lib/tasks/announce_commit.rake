namespace :telegram do
  desc "Sends the contents of CHANGELOG into the designated channel."

  task :announce_commit do
    if Rails.application.credentials.telegram.channel_id
      if File.exists?("#{Rails.root}/CHANGELOG")
        Telegram.bot.send_message(
          chat_id: Rails.application.credentials.telegram.channel_id,
          disable_web_page_preview: true,
          text: File.read("#{Rails.root}/CHANGELOG"),
          parse_mode: "html"
        )
        puts("Posted the changelog message!")
      else
        puts("No CHANGELOG file provided, doing nothing.")
      end
    else
      puts "No changelog channel has been defined in the credentials, doing nothing."
    end
  end
end
