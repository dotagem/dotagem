class UsersController < ApplicationController
  before_action :current_user_or_admin

  def unlink_steam
    @user = User.find(params[:id])

    @user.steam_id64 = nil
    @user.steam_id = nil
    @user.steam_nickname = nil
    @user.steam_url = nil
    @user.steam_avatar = nil

    @user.save
    
    flash[:notice] = "Your Steam account has been unlinked, feel free to link a different one!"
    redirect_to root_url, status: 303
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:notice] = "Your registration has been removed. Feel free to log in again if you change your mind!"
    redirect_to root_url, status: 303
  end

  private

  def current_user_or_admin
    unless current_user.admin? || User.find(params[:id]) == current_user
      flash[:error] = "You're not allowed to do that!"
      redirect_to root_url, status: 303
    end
  end
end
