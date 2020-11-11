# frozen_string_literal: true

class ChannelsController < ApplicationController
  include CurlBuilder

  def show
    @channels = Channel.where(app_id: session[:app_id])
    @channel = Channel.find(params[:id])

    @pushed_count = Transception.count
    @is_read = Transception.where(is_read: true).count

    bot_token = ENV["OAUTH_BOT_TOKEN"]
    bot_user_id = ENV["BOT_USER_ID"]

    user_info = curl_exec(base_url: "https://slack.com/api/users.info?user=#{bot_user_id}", headers: { "Authorization": "Bearer " + bot_token })
    @user_info_realname = JSON.parse(user_info[0])["user"]["real_name"]
    @user_info_profile_image = JSON.parse(user_info[0])["user"]["profile"]["image_192"]

    @messages = Message.where(channel_id: params[:id]).sort_by do |message|
      [message.push_timing.in_x_days, message.push_timing.time.to_i]
    end
  end
end
