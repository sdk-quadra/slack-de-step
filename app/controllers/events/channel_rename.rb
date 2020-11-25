class Events::ChannelRename

  def execute(params)
    # #
    # channel名を変更した時の処理
    # #

    channel = params[:event][:channel]

    Channel.find_by(slack_channel_id: channel[:id]).update(name: channel[:name])

  end

end
