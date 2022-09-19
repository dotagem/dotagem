module HeroPlayerOptions
  def build_and_validate_options(args)
    delimiters = ["as", "with", "against", "and"]

    # Prepare the array
    prepared_args = []
    args.each do |a|
      prepared_args << a.downcase.tr("@", "")
    end
    
    prepared_args.delete_at(0) if User.find_by(telegram_username: prepared_args[0])
    return {} unless prepared_args.any?

    # Split it up
    chunks = prepared_args.chunk { |v| v.in?(delimiters) }.to_a
    # Array must start with a true chunk and end with a false one
    # It's okay to insert an invalid value here, we just don't want to
    # throw an exception at this stage
    chunks.unshift [true, ["as"]] if chunks.first[0] == false
    chunks.push    [false, [""] ] if chunks.last[0]  == true
    # Build the array
    options = []
    chunks.each_with_index do |c, i|
      if c[0] == true
        options << { mode: c[1].join(" "), value: chunks[i+1][1].join(" ") }
      end
    end

    return false if options.first[:mode] == "and"
    options.each_with_index do |o, i|
      o[:mode] = o[:mode].split(" ").last
      if o[:mode] == "and"
        o[:mode] = options[i - 1][:mode]
      end
    end

    # Validation time!
    return false if options.count { |o| o[:mode] == "as" } > 1
    return false if options.count > 10
    options.each do |o|
      return false unless o[:mode].in?(delimiters)
      return false if     o[:value].blank?
      return false unless hero_or_player(o[:value])
      return false if     (o[:mode] == "as" || o[:mode] == "against") &&
                          User.find_by(telegram_username: o[:value])
    end

    # Construct query hash
    query = {}
    options.each do |o|
      if User.find_by(telegram_username: o[:value])
        query[:included_account_id] ||= []
        query[:included_account_id] << User.find_by(telegram_username: o[:value]).steam_id
      else # Alias
        if o[:mode] == "as"
          query[:hero_id] = resolve_alias(o[:value])
        elsif o[:mode] == "with"
          query[:with_hero_id] ||= []
          query[:with_hero_id] << resolve_alias(o[:value])
        else # mode == "against"
          query[:against_hero_id] ||= []
          query[:against_hero_id] << resolve_alias(o[:value])
        end
      end
    end
    return query
  end

  def clean_up_options(options)
    if Hash === options[:hero_id] && options[:hero_id][:result]
      options[:hero_id] = options[:hero_id][:result]
    end
    if options[:with_hero_id]
      options[:with_hero_id].each_with_index do |h, i|
        if Hash === h && h[:result]
          options[:with_hero_id][i] = h[:result]
        end
      end
    end
    if options[:against_hero_id]
      options[:against_hero_id].each_with_index do |h, i|
        if Hash === h && h[:result]
          options[:against_hero_id][i] = h[:result]
        end
      end
    end
    options
  end

  def hero_or_player(string)
    Nickname.find_by(name: string.downcase) || User.find_by(telegram_username: string.downcase)
  end

  def resolve_alias(string)
    aliases = Nickname.where(name: string)
    if aliases.any?
      if aliases.count == 1
        aliases.first.hero.hero_id
      else
        # We'll find these later
        {query: string}
      end
    end
  end
end
