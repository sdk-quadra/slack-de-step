# frozen_string_literal: true

module SlackApiBlocks
  extend ActiveSupport::Concern

  def test_blocks_text_with_image(message)
    blocks = "[{\"block_id\": \"test_message\", \"type\": \"section\",\"text\": {\"type\": \"mrkdwn\", \"text\": \"#{message.message}\"}}, {\"type\": \"image\", \"title\": {\"type\": \"plain_text\",\"text\": \"pitcure\"}, \"image_url\": \"#{message.image_url}\", \"block_id\": \"image4\",\"alt_text\": \"pitcure here\"}]"
    blocks
  end

  def test_blocks_text(message)
    blocks = "[{\"block_id\": \"test_message\", \"type\": \"section\",\"text\": {\"type\": \"mrkdwn\", \"text\": \"#{message.message}\"}}]"
    blocks
  end

  def schedule_blocks_text_with_image(message)
    blocks = "[{\"block_id\": \"#{message.id}\", \"type\": \"section\",\"text\": {\"type\": \"mrkdwn\", \"text\": \"#{message.message}\"}}, {\"type\": \"image\", \"title\": {\"type\": \"plain_text\",\"text\": \"pitcure\"}, \"image_url\": \"#{message.image_url}\", \"block_id\": \"image4\",\"alt_text\": \"pitcure here\"}]"
    blocks
  end

  def schedule_blocks_text(message)
    blocks = "[{\"block_id\": \"#{message.id}\", \"type\": \"section\",\"text\": {\"type\": \"mrkdwn\", \"text\": \"#{message.message}\" }}]"
    blocks
  end
end
