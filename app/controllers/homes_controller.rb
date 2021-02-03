# frozen_string_literal: true

class HomesController < ApplicationController
  ## TODO: cross origin対策
  protect_from_forgery except: :server
  skip_before_action :check_logged_in
  before_action :already_logged_in

  include Builders::ChannelBuilder
  include Builders::CryptBuilder

  def index
  end

  def server
    if params[:challenge]
      render body: params[:challenge]
    else
      event(params)
    end
  end

  def privacy_policy
  end

  private
    def event(params)
      event_type = params[:event][:type]
      Channel.event_case(params, event_type)

      render status: 200, json: { status: 200 }
    end

    def already_logged_in
      if session[:workspace_id]
        app_id = Companion.find_by(slack_user_id: session[:authed_slack_user_id]).app_id
        redirect_to channel_path(general_channel(app_id))
      end
    end
end
