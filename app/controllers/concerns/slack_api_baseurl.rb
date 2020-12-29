# frozen_string_literal: true

module SlackApiBaseurl
  extend ActiveSupport::Concern

  def url_users_identity
    base_url = "https://slack.com/api/users.identity"
    base_url
  end

  def url_users_list
    base_url = "https://slack.com/api/users.list"
    base_url
  end

  def url_conversations_list
    base_url = "https://slack.com/api/conversations.list"
    base_url
  end

  def url_conversations_join
    base_url = "https://slack.com/api/conversations.join"
    base_url
  end

  def url_conversations_info
    base_url = "https://slack.com/api/conversations.info"
    base_url
  end

  def url_conversations_members
    base_url = "https://slack.com/api/conversations.members"
    base_url
  end

  def url_users_info
    base_url = "https://slack.com/api/users.info"
    base_url
  end

  def url_chat_schedule_message
    base_url = "https://slack.com/api/chat.scheduleMessage"
    base_url
  end

  def url_chat_post_message
    base_url = "https://slack.com/api/chat.postMessage"
    base_url
  end

  def url_chat_delete_scheduled_message
    base_url = "https://slack.com/api/chat.deleteScheduledMessage"
    base_url
  end
end
