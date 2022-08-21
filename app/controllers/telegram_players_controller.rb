class TelegramPlayersController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext

  before_action :logged_in_or_mentioning_player, only: [:winrate!, :wl!]

  def winrate!(*args)
    args[0] = args[0].tr("@", "") if args.any?
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

      @data = @player.win_loss(wl_query(@mode, @a.hero))
    else
      @data = @player.win_loss
    end

    message = ""
    message << "#{@mode.capitalize} #{@a.hero.localized_name}: " if args.any? 
    message << "#{@data["win"]} wins, #{@data["lose"]} losses"
    reply_with :message, text: message
  end

  alias_method :wl!, :winrate!

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

  def logged_in_or_mentioning_player
    _, args = Telegram::Bot::UpdatesController::Commands.command_from_text(payload['text'], bot_username)
    args[0] = args[0].tr("@", "") if args.any?
    @player = User.find_by(telegram_username: args[0]) ||
              User.find_by(telegram_id: from["id"])
    if @player.nil?
      respond_with :message, text: "Can't find that user!"
      throw(:filtered)
    elsif @player.steam_registered? == false
      respond_with :message, text: "That user has not completed their registration!"
    end
  end
end
