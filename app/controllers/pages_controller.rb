class PagesController < ApplicationController
  before_action :logged_in_user, only: [:admin]
  before_action :admin_user,     only: [:admin]

  def home
  end

  def help
  end

  def commands
  end

  def admin
    aliases     = Alias.count
    heroes      = Hero.count
    game_modes  = GameMode.count
    heroes      = Hero.count
    items       = Item.count
    lobby_types = LobbyType.count
    patches     = Patch.count
    regions     = Region.count
  end
end
