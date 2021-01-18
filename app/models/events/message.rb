# frozen_string_literal: true

class Events::Message
  def execute(params)
    # #
    # messageを受信した時の処理
    # #

    return if params[:event][:subtype].present?
    return if params[:event][:user] == "USLACKBOT"

    user = params[:event][:user]
    channel = params[:event][:channel]
    message_id = params[:event][:blocks][0][:block_id]

    Transception.save_transception(user, channel, message_id)
  end
end
