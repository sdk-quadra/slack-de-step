# frozen_string_literal: true

class Events::Message
  def execute(params)
    # #
    # messageを受信した時の処理
    # #

    user = params[:event][:user]
    channel = params[:event][:channel]

    return if params[:event][:subtype].present?

    message_id = params[:event][:blocks][0][:block_id]

    # messageで受けるイベントは複数ある為,bot_user_idで選別
    from_bot = App.exists?(bot_user_id: user)

    is_test_message = message_id == "test_message" ? true : false

    if from_bot && !is_test_message
      Transception.new(conversation_id: channel, message_id: message_id.to_i).save!
    end
  end
end
