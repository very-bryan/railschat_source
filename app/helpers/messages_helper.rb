module MessagesHelper
  def should_show_header?(message, previous_message)
    return true if previous_message.nil?
    return true if message.user_id != previous_message.user_id
    return true if message.created_at - previous_message.created_at > 5.minutes
    false
  end
  
  def format_message_time(message)
    message.created_at.strftime("%H:%M")
  end
  
  def getFileIconServer(extension)
    icons = {
      'pdf' => '📄',
      'doc' => '📝', 'docx' => '📝',
      'xls' => '📊', 'xlsx' => '📊',
      'ppt' => '📊', 'pptx' => '📊',
      'zip' => '🗜️', 'rar' => '🗜️',
      'txt' => '📃'
    }
    icons[extension.to_s.downcase] || '📎'
  end
end
