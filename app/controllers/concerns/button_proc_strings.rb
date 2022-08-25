module ButtonProcStrings
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::TextHelper

  def match_button_proc_string
    %{
      Proc.new do |m|
        duration = m.duration / 60
        text = "\#{m.wl} \#{duration}min \#{m.rd} \#{m.kills}/\#{m.deaths}/\#{m.assists} " +
        "\#{Hero.find_by(hero_id: m.hero_id).localized_name} " +
        "\#{time_ago_in_words(Time.at(m.start_time))} ago"
        callback = "nothing:0"
        next text, callback
      end
    }
  end

  def peer_button_proc_string
    # User.find_by(steam_id: p.account_id).telegram_username
    %{
      Proc.new do |p|
        win_percentage = (p.with_win.to_f / p.with_games * 100).round(2)
        text = "\#{p.personaname}: " +
        "\#{p.with_games} games, \#{win_percentage}% wr, " +
        "last \#{time_ago_in_words(Time.at(p.last_played))} ago"
        callback = "matches_with:\#{p.account_id}"
        next text, callback
      end
    }
  end

  def hero_as_button_proc_string
    %{
      Proc.new do |h|
        games   = h.games
        winrate = (h.win / games.to_f * 100).round(2)
        text = "\#{h.localized_name}: " +
        "\#{games}, \#{winrate}% wr, " +
        "last \#{time_ago_in_words(Time.at(h.last_played))} ago"
        callback = "matcheswithhero:7\#{h.hero_id}"
        next text, callback
      end
    }
  end

  def hero_with_button_proc_string
    %{
      Proc.new do |h|
        games   = h.games_with
        winrate = (h.win_with / games.to_f * 100).round(2)
        text = "\#{h.localized_name}: " +
        "\#{games} with, \#{winrate}% wr, " +
        "last \#{time_ago_in_words(Time.at(h.last_played))} ago"
        callback = "matcheswithhero:7\#{h.hero_id}"
        next text, callback
      end
    }
  end

  def hero_against_button_proc_string
    %{
      Proc.new do |h|
        games   = h.games_against
        winrate = (h.win_against / games.to_f * 100).round(2)
        text = "\#{h.localized_name}: " +
        "\#{games} against, \#{winrate}% wr, " +
        "last \#{time_ago_in_words(Time.at(h.last_played))} ago"
        callback = "matcheswithhero:7\#{h.hero_id}"
        next text, callback
      end
    }
  end
end
