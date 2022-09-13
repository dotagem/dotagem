module ButtonProcStrings
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::TextHelper

  private
  
  def match_button_proc_string
    %{
      Proc.new do |m|
        duration = m.duration / 60
        text = "\#{m.wl} \#{duration}min \#{m.rd} \#{m.kills}/\#{m.deaths}/\#{m.assists} " +
        "\#{hero_name(m.hero_id)} " +
        "\#{time_ago_in_words(Time.at(m.start_time))} ago"
        callback = "nothing:0"
        next text, callback
      end
    }
  end

  def peer_button_proc_string
    %{
      Proc.new do |p|
        win_percentage = (p.with_win.to_f / p.with_games * 100).round(2)
        text = "\#{User.find_by(steam_id: p.account_id).telegram_username}: " +
        "\#{p.with_games} games, \#{win_percentage}%, " +
        "last \#{time_ago_in_words(Time.at(p.last_played))} ago"
        callback = "matches_with_player:\#{p.account_id}"
        next text, callback
      end
    }
  end

  def hero_as_button_proc_string
    %{
      Proc.new do |h|
        games   = h.games
        winrate = (h.win / games.to_f * 100).round(2)
        text = "\#{h.localized_name}: \#{games} games"
        if h.games > 0
          text << ", \#{winrate}%, " +
          "last \#{time_ago_in_words(Time.at(h.last_played))} ago"
        end
        callback = "matches_hero:\#{h.hero_id}"
        next text, callback
      end
    }
  end

  def hero_with_button_proc_string
    %{
      Proc.new do |h|
        games   = h.with_games
        winrate = (h.with_win / games.to_f * 100).round(2)
        text = "\#{h.localized_name}: \#{games} with"
        if h.with_games > 0
          text << ", \#{winrate}%"
        end
        callback = "matches_hero:\#{h.hero_id}"
        next text, callback
      end
    }
  end

  def hero_against_button_proc_string
    %{
      Proc.new do |h|
        games   = h.against_games
        winrate = (h.against_win / games.to_f * 100).round(2)
        text = "\#{h.localized_name}: \#{games} against"
        if h.against_games > 0
          text << ", \#{winrate}%"
        end
        callback = "matches_hero:\#{h.hero_id}"
        next text, callback
      end
    }
  end

  def matchup_button_proc_string
    %{
      Proc.new do |h|
        wilson = h.wilson_against.round(2)
        text = "\#{h.localized_name}: \#{h.against_win}/\#{h.against_games} games, \#{wilson} score"
        callback = "nothing:0"
        next text, callback
      end
    }
  end
end
