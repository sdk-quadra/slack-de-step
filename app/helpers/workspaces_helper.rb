# frozen_string_literal: true

module WorkspacesHelper
  def general_channel(app_id)
    Channel.where(name: "general").find_by(app_id: app_id)
  end
end
