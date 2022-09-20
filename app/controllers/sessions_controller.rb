class SessionsController < ApplicationController
  require 'steam_id'
  # Only the highest quality code here
  skip_before_action :verify_authenticity_token, only: [:steam]
  before_action :logged_in_user, only: [:steam, :destroy]

  def telegram
    auth = request.env['omniauth.auth']

    # Refresh user data if they're known, else create new user
    user = User.find_or_create_by(telegram_id: auth['uid'])
    user.telegram_username = auth['info']['nickname'].downcase
    user.telegram_avatar   = auth['info']['image']
    user.telegram_name     = auth['info']['name']

    # Solve a specific race condition where two users can have the same Telegram username
    if User.where(telegram_username: user.telegram_username).any?
      User.where(telegram_username: user.telegram_username).each do |u|
        unless user == u
          u.telegram_username = "[#{u.telegram_id}]"
          u.save!
        end
      end
    end
    user.save!

    log_out if logged_in?
    log_in(user)
    redirect_to '/'
  end

  def steam
    auth = request.env['omniauth.auth']

    # Find and remove this steam account from users who aren't our current user
    users_with_steamid = User.where(steam_id64: auth['uid'])
    unless users_with_steamid.empty?
      users_with_steamid.each do |u|
        unless current_user?(u)
          u.steam_id64     = nil
          u.steam_id       = nil
          u.steam_nickname = nil
          u.steam_url      = nil
          u.steam_avatar   = nil
          u.save!

          flash[:notice] = "There was at least one other user with this Steam account" +
                           " connected, their Steam account has been unset."
        end
      end
    end

    current_user.steam_id64     = auth['uid']
    current_user.steam_id       = SteamID.from_string(auth['uid']).account_id
    current_user.steam_nickname = auth['info']['nickname']
    current_user.steam_url      = auth['info']['urls']['Profile']
    current_user.steam_avatar   = auth['extra']['raw_info']['avatarfull']

    current_user.save!
    redirect_to '/'
  end

  def destroy
    log_out
    redirect_to '/'
  end

  def failure
    flash[:error] = "Login unsuccessful, please try again!"
    redirect_to root_url
  end
end
