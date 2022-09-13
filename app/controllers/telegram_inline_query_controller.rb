class TelegramInlineQueryController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::Session

  include MatchMessages
  include LoginUrl

  def inline_query(query, _offset)
    @player ||= User.find_by(telegram_id: from['id'])
    
    if @player && @player.steam_registered?
      results = []

      # Figure out aliases
      if query.blank?
        @matches = @player.matches(limit: 10)
      else
        aliases = Alias.where(name: query.downcase)
        case aliases.count
        when 0
          @matches = @player.matches(limit: 10)
        when 1
          @matches = @player.matches(limit: 10, hero_id: aliases.first.hero.hero_id)
        else
          matcharray = []
          aliases.each do |a|
            matcharray += @player.matches(limit: 10, hero_id: a.hero.hero_id)
          end
          matcharray.sort_by! { |m| m.start_time }.reverse!
          @matches = matcharray[0..9]
        end
      end

      # Build results
      @matches.each do |lm|
        results << build_inline_result(lm)
      end

      answer_inline_query(results, is_personal: true)
    else
      answer_inline_query(
        [],
        is_personal:         true,
        # Should not be kept for long, user will want to try again after logging in
        cache_time:          10,
        switch_pm_text:      "Log in with Steam",
        switch_pm_parameter: "login"
      )
    end
  end
end

private

def build_inline_result(lm)
  result = {
    type: "article",
    id: lm.match_id,
    thumb_url: Hero.find_by(hero_id: lm.hero_id).icon_url,
    title: "#{lm.won? ? "Win" : "Loss"} as #{hero_name(lm.hero_id)}",
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
