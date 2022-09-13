class TelegramInlineQueryController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::Session

  include MatchMessages
  include LoginUrl

  def inline_query(query, _offset)
    @player ||= User.find_by(telegram_id: from['id'])
    results = []

    if @player && @player.steam_registered?
      # Figure out alias

      @matches = @player.matches(limit: 10)

      # Build results
      @matches.each do |lm|
        results << build_inline_result(lm)
      end
    else
      results << {
        type: "article",
        id: 1,
        title: "You need to sign in before I can show your recent matches!",
        description: "Go to dotagem.net or send this message and sign in with Steam.",
        input_message_content: {
          message_text: "To use the bot, I will need to know which Telegram account" + 
          " belongs to which Steam account. Use the button below to sign in, then" +
          " sign in with Steam as well and I will be able to show your matches!"
        },
        reply_markup: {
          inline_keyboard: [[
            {
              text: "Log In",
              login_url: {url: login_callback_url}
            }
          ]]
        }
      }
    end

    answer_inline_query(results)
  end
end

private

def build_inline_result(lm)
  result = {
    type: "article",
    id: lm.match_id,
    thumb_url: Hero.find_by(hero_id: lm.hero_id).icon_url,
    title: "#{lm.won? ? "Win" : "Loss"} as #{Hero.find_by(hero_id: lm.hero_id).localized_name}",
    description: "#{lm.kills}/#{lm.deaths}/#{lm.assists} in #{lm.duration / 60} min\n" + 
    "#{time_ago_in_words(Time.at(lm.start_time))} ago",
    input_message_content: {
      message_text: build_short_match_message(lm)
    },
    reply_markup: {
      inline_keyboard: build_match_overview_keyboard(lm)
    }
  }

  result
end
