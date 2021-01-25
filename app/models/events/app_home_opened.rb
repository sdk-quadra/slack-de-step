# frozen_string_literal: true

class Events::AppHomeOpened
  def execute(params)
    channel = params[:event][:channel]

    transception = Transception.where(conversation_id: channel)
    transception.update(is_read: true)
  end
end
