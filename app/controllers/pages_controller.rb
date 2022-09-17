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
    @nickname_count     = Nickname.count
    @game_mode_count    = GameMode.count
    @hero_count         = Hero.count
    @hero_last          = Hero.last.localized_name
    @item_count         = Item.count
    @lobby_type_count   = LobbyType.count
    @patch_count        = Patch.count
    @patch_last         = Patch.last.name
    @region_count       = Region.count
  end 
end
