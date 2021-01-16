# frozen_string_literal: true

module SlackApiBaseurl
  extend ActiveSupport::Concern

  USERS_IDENTITY = "https://slack.com/api/users.identity"
  USERS_LIST = "https://slack.com/api/users.list"
  CONVERSATIONS_LIST = "https://slack.com/api/conversations.list"
  CONVERSATIONS_JOIN = "https://slack.com/api/conversations.join"
  CONVERSATIONS_INFO = "https://slack.com/api/conversations.info"
  CONVERSATIONS_MEMBERS = "https://slack.com/api/conversations.members"
  USERS_INFO = "https://slack.com/api/users.info"
  CHAT_POST_MESSAGE = "https://slack.com/api/chat.postMessage"
  CHAT_SCHEDULE_MESSAGE = "https://slack.com/api/chat.scheduleMessage"
  CHAT_DELETE_SCHEDULED_MESSAGE = "https://slack.com/api/chat.deleteScheduledMessage"
end
