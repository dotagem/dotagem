module MessageSession
  protected

  def session_key
    # If we're in a callback query, associate default session with message ID
    if update['callback_query']
      "#{bot_username}:#{chat['id']}:#{update['callback_query']['message']['message_id']}"
    end
  end

  def message_session(message_id=nil)
    @_message_session ||= self.class.build_session(chat && message_id &&
                          "#{bot.username}:#{chat['id']}:#{message_id}")
  end

  def process_action(*)
    super
  ensure
    message_session.commit if @_message_session
  end
end
