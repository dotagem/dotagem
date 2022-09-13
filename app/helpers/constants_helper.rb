module ConstantsHelper
  def hero_name(hero_id=nil)
    if hero_id
      Hero.find_by(hero_id: hero_id).localized_name
    else
      "Unknown Hero"
    end
  end

  def item_name(item_id=nil)
    if item_id
      Item.find_by(item_id: item_id).localized_name
    else
      "Unknown Item"
    end
  end

  def lobby_type_name(lobby_id=nil)
    if lobby_id
      LobbyType.find_by(lobby_id: lobby_id).localized_name
    else
      "Unknown Lobby Type"
    end
  end

  def patch_name(patch_id=nil)
    if patch_id
      Patch.find_by(patch_id: patch_id).name
    else
      "Unknown Patch"
    end
  end

  def region_name(region_id=nil)
    if region_id
      Region.find_by(region_id: region_id).localized_name
    else
      "Unknown Region"
    end
  end

  def game_mode_name(mode_id=nil)
    if mode_id
      GameMode.find_by(mode_id: mode_id).localized_name
    else
      "Unknown Mode"
    end
  end
end
