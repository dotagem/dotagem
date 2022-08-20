class TelegramPlayersController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext

  def winrate!(*args)
    player = User.find_by(telegram_username: args[0]) ||
             User.find_by(telegram_id: from["id"])
    if player.nil?
      reply_with :message, text: "Can't find that user, please log in!"
      return false
    end
    args.delete_at(0) if User.find_by(telegram_username: args[0])

    if args.any?
      if args[0].in?(["as", "with", "against"])
        @mode = args[0]
        args.delete_at(0)
      else
        @mode = "as"
      end

      @a = Alias.find_by(name: args.join(" "))
      if @a.nil?
        reply_with :message, text: "Can't find that hero!"
        return false
      end

      @data = player.win_loss(wl_query(@mode, @a.hero))
    else
      @data = player.win_loss
    end

    message = ""
    message << "#{@mode.capitalize} #{@a.hero.localized_name}: " if args.any? 
    message << "#{@data["win"]} wins, #{@data["lose"]} losses"
    reply_with :message, text: message
  end
end

private

def wl_query(mode, hero)
  if    mode == "as"
    {hero_id: hero.hero_id}
  elsif mode == "with"
    {with_hero_id: hero.hero_id}
  else
    {against_hero_id: hero.hero_id}
  end
end
