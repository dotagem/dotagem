module ErrorHandling
  
  private
  def error_out(exception)
    # Collect backtrace and error information
    backtrace_size = exception.backtrace.size
    if backtrace_size >= 2 then max_range = 2
    elsif backtrace_size >= 1 then max_range = 1
    end
    if max_range > 0      
      s = "rescued_from: #{exception.inspect}\n#{exception.backtrace[0..max_range].to_s}\n"
      logger.error s
    end

    # Send a message with helpful information about what to do next
    if update["message"]
      bot.send_message(
        text: "Something went wrong, sorry!\n" +
        "When reporting this error, please provide the following information:\n\n" +
        "Update ID: #{update["update_id"]}\n" +
        "Error:\n<pre>#{CGI::escapeHTML(exception.inspect)}</pre>",
        parse_mode: "html",
        chat_id: update["message"]["chat"]["id"]
      )
    elsif update["callback_query"]
      bot.send_message(
        chat_id: update["callback_query"]["message"]["chat"]["id"],
        text: "Something went wrong, sorry!\n" +
        "When reporting this error, please provide the following information:\n\n" +
        "Update ID: #{update["update_id"]}\n" +
        "Error:\n<pre>#{CGI::escapeHTML(exception.inspect)}</pre>",
        parse_mode: "html"
      )
      answer_callback_query "Something went wrong, sorry!"
    elsif update["inline_query"]
      bot.answer_inline_query(
        inline_query_id: update["inline_query"]["id"],
        results: [
          {
            type: "article",
            id: 0,
            title: "Something went wrong, sorry!",
            description: "Send this message for error details.",
            input_message_content: {
              message_text: "Something went wrong, sorry!\n" +
              "When reporting this error, please provide the following information:\n\n" +
              "Update ID: #{update["update_id"]}\n" +
              "Error:\n<pre>#{CGI::escapeHTML(exception.inspect)}</pre>",
              parse_mode: "html"
            }
          }
        ],
        cache_time: 10
      )
    end
  end 
end
