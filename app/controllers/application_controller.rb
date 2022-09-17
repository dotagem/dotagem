class ApplicationController < ActionController::Base
  include SessionsHelper

  private
    def logged_in_user
      unless logged_in?
        flash[:error] = "You need to sign in with Telegram first!"
        redirect_to root_url, status: 303
      end
    end

    def admin_user
      unless logged_in? && current_user.admin?
        flash[:error] = "You do not have permission to go there!"
        redirect_to root_url, status: 303
      end
    end
end
