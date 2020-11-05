# frozen_string_literal: true

class CurlBuilder
  def build(base_url:, method: "GET", params: {}, headers: {}, body_filename: nil, verbose: true, silent: true, options: "")
    url = base_url
    url += "?" + URI.encode_www_form(params) unless params.empty?
    cmd = "curl '#{url}'"
    cmd += " -d '@#{body_filename}'" if body_filename
    cmd += " " + headers.map { |k, v| "-H '#{k}: #{v}'" }.join(" ") + " " unless headers.empty?
    # cmd += " -v " if verbose
    cmd += " -s " if silent
    # cmd += options
    cmd
  end

  def exec(*args, **kwargs)
    cmd = build(*args, **kwargs)
    o, e, s = Open3.capture3(cmd)
  end
end

class ChannelsController < ApplicationController
  def index; end

  def new; end

  def show
    curl = CurlBuilder.new
    bot_token = ENV["OAUTH_BOT_TOKEN"]
    bot_user_id = ENV["BOT_USER_ID"]

    user_info = curl.exec(base_url: "https://slack.com/api/users.info?user=#{bot_user_id}", headers: { "Authorization": "Bearer " + bot_token })
    @user_info_realname = JSON.parse(user_info[0])["user"]["real_name"]
    @user_info_profile_image = JSON.parse(user_info[0])["user"]["profile"]["image_192"]

    @messages_sorted = Message.where(channel_id: params[:id]).sort_by do |message|
      [message.push_timing.in_x_days, message.push_timing.time.to_i]
    end
  end
end
