module LoginUrl
  private
  
  def login_callback_url
    "#{Rails.application.credentials.base_url}/auth/telegram/callback"
  end
end
