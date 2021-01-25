# frozen_string_literal: true

module OwnChecker
  def check_channel_owner(workspace_id, channel_id)
    accessible_channels = accessible_channels(workspace_id)

    render_404 unless accessible_channels.include?(channel_id)
  end

  def check_message_owner(workspace_id, message_id)
    accessible_channels = accessible_channels(workspace_id)
    accessible_messages = Message.where(channel_id: accessible_channels).map(&:id)

    render_404 unless accessible_messages.include?(message_id)
  end

  def accessible_channels(workspace_id)
    app_id = App.find_by(workspace_id: workspace_id).id
    Channel.where(app_id: app_id).map(&:id)
  end

  def render_404
    render file: Rails.root.join("public/404.html"), status: 404, layout: false, content_type: "text/html"
  end
end
