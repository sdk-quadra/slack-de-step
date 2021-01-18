# frozen_string_literal: true

class Participation < ApplicationRecord
  belongs_to :channel
  belongs_to :companion

  class << self
    def participate_channel(user, channel_to_join, companion)
      unless App.exists?(bot_user_id: user)
        Participation.find_or_create_by!(companion_id: companion.id, channel_id: channel_to_join.id) do |p|
          p.companion_id = companion.id
          p.channel_id = channel_to_join.id
        end
      end
    end

    def participate_new_channel(members, channel)
      members.each do |member|
        companion_id = Companion.find_by(slack_user_id: member).id
        channel_id = Channel.find_by(slack_channel_id: channel[:id]).id

        unless App.exists?(bot_user_id: member)
          Participation.find_or_create_by!(companion_id: companion_id, channel_id: channel_id) do |p|
            p.companion_id = companion_id
            p.channel_id = channel_id
          end
        end
      end
    end

    def destroy_participation(companion, channel_to_leave)
      participation = Participation.find_by(companion_id: companion.id, channel_id: channel_to_leave.id)
      participation.destroy unless participation.nil?
    end
  end
end
