module ErrorHandling
  
  private
  def error_out(exception)
    backtrace_size = exception.backtrace.size
    if backtrace_size >= 2 then max_range = 2
    elsif backtrace_size >= 1 then max_range = 1
    end
    if max_range > 0      
      s = "rescued_from: #{exception.inspect}\n#{exception.backtrace[0..max_range].to_s}\n"
      logger.error s
    end

    if update["message"]
      bot.send_message(
        text: "Something went wrong, sorry!",
        chat_id: update["message"]["chat"]["id"]
      )
    elsif update["callback_query"]
      bot.answer_callback_query(
        text: "Something went wrong, sorry!",
        callback_query_id: update["callback_query"]["id"]
      )
    elsif update["inline_query"]
      bot.answer_inline_query(
        inline_query_id: update["inline_query"]["id"],
        results: [
          {
            type: "article",
            id: 0,
            title: "Something went wrong, sorry!"
          }
        ],
        cache_time: 10
      )
    end
  end 
end
