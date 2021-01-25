# frozen_string_literal: true

class Events::ChannelRename
  def execute(params)
    channel = params[:event][:channel]
    Channel.find_by(slack_channel_id: channel[:id]).update(name: channel[:name])
  end
end
