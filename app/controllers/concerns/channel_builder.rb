# frozen_string_literal: true

module ChannelBuilder
  extend ActiveSupport::Concern

  def member_count(channel)
    member_count = Channel.find_by(slack_channel_id: channel).participations.count
    Channel.find_by(slack_channel_id: channel).update(member_count: member_count)
  end

  def general_channel(app_id)
    general_channel = Channel.where(name: "general").find_by(app_id: app_id)
    general_channel
  end
end
