module LoginUrl
  private

  def login_callback_url
    "#{ENV['BASE_URL']}/auth/telegram/callback"
  end
end
