# frozen_string_literal: true

module ChannelBuilder
  extend ActiveSupport::Concern

  def member_count(channel)
    member_count = Channel.find_by(slack_channel_id: channel).participations.count
    Channel.find_by(slack_channel_id: channel).update(member_count: member_count)
  end
end
