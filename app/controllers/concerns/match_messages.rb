module MatchMessages
  include ActionView::Helpers::DateHelper

  PAGE_ITEMS = 5

  def build_matches_header(matches, options=nil)
    message = ["Matches"]
    if options
      message << build_options_message(options)
    end

    message << "#{matches.count} results"
    message.join("\n")
  end

  def build_options_message(options)
    message = []
    @unresolved = 0

    if options[:hero_id]
      message << "Playing as #{hero_name_or_alias(options[:hero_id])}"
    end
    if options[:included_account_id]
      accounts = []
      options[:included_account_id].each do |account|
        accounts << Player.find_by(steam_id: account).telegram_username
      end
      message << "With players: #{accounts.join(", ")}"
    end

    if options[:with_hero_id]
      heroes = []
      options[:with_hero_id].each do |hero_id|
        heroes << hero_name_or_alias(hero_id)
      end
      message << "Allied heroes: #{heroes.join(", ")}"
    end
    if options[:against_hero_id]
      heroes = []
      options[:against_hero_id].each do |hero_id|
        heroes << hero_name_or_alias(hero_id)
      end
      message << "Enemy heroes: #{heroes.join(", ")}"
    end

    message
  end

  def hero_name_or_alias(input)
    case input
    when Integer
      Hero.find_by(hero_id: input).localized_name
    else # Expecting hash
      @unresolved ||= 0
      @unresolved = @unresolved + 1
      @unresolved < 2 ? ">>\"#{input[:query]}\"<<" : "\"#{input[:query]}\""
    end
  end

  def build_matches_buttons(matches, page=1)
    i = (page - 1) * PAGE_ITEMS
    subset = matches[i..i+PAGE_ITEMS-1]
    keyboard = []
    subset.each do |match|
      keyboard << [
        {
          text: match_button_text(match),
          callback_data: "nothing:0" 
        }
      ]
    end

    pages = matches.count / PAGE_ITEMS
    if (matches.count % PAGE_ITEMS) > 0
      pages = pages + 1
    end
    
    if pages > 1
      row  = []
      if page > 1
        if page > 2
          row << {
              text: "|<<",
              callback_data: "pagination:1"
          }
        end
        row << {
          text: "<",
          callback_data: "pagination:#{page-1}"
        }
      end
      row << {
        text: "#{page} / #{pages}",
        callback_data: "nothing:0"
      }
      if page < pages
        row << {
          text: ">",
          callback_data: "pagination:#{page+1}"
        }
        if page < pages - 1
          row << {
            text: ">>|",
            callback_data: "pagination:#{pages}"
          }
        end
      end
      keyboard << row
    end

    return keyboard
  end

  def match_button_text(m)
    duration = m.duration / 60
    "#{m.wl} #{duration}min #{m.rd} #{m.kills}/#{m.deaths}/#{m.assists} " +
    "#{Hero.find_by(hero_id: m.hero_id).localized_name} " +
    "#{time_ago_in_words(Time.at(m.start_time))} ago"
  end
end
