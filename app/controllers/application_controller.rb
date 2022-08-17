class ApplicationController < ActionController::Base
  include SessionsHelper

  private
    def logged_in_user
      unless logged_in?
        flash[:danger] = "You need to sign in with Telegram first!"
        redirect_to '/' 
      end
    end
end
