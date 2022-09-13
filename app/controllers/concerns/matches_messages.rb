module MatchesMessages
  include ActionView::Helpers::DateHelper
  include ConstantsHelper

  PAGE_ITEMS = 5

  def build_matches_header(matches, options=nil)
    message = ["Matches for #{@player.telegram_username}"]
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
        accounts << User.find_by(steam_id: account).telegram_username
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
      hero_name(input)
    else # Expecting hash
      @unresolved ||= 0
      @unresolved = @unresolved + 1
      @unresolved < 2 ? ">>\"#{input[:query]}\"<<" : "\"#{input[:query]}\""
    end
  end
end
