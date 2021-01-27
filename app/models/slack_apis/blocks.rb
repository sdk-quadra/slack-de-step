# frozen_string_literal: true

module SlackApis
  module Blocks
    def test_blocks_text_with_image(message)
      "[{\"block_id\": \"test_message\", \"type\": \"section\",\"text\": {\"type\": \"mrkdwn\", \"text\": \"#{message.message}\"}}, {\"type\": \"image\", \"title\": {\"type\": \"plain_text\",\"text\": \"pitcure\"}, \"image_url\": \"#{message.image_url}\", \"block_id\": \"image4\",\"alt_text\": \"pitcure here\"}]"
    end

    def test_blocks_text(message)
      "[{\"block_id\": \"test_message\", \"type\": \"section\",\"text\": {\"type\": \"mrkdwn\", \"text\": \"#{message.message}\"}}]"
    end

    def schedule_blocks_text_with_image(message)
      "[{\"block_id\": \"#{message.id}\", \"type\": \"section\",\"text\": {\"type\": \"mrkdwn\", \"text\": \"#{message.message}\"}}, {\"type\": \"image\", \"title\": {\"type\": \"plain_text\",\"text\": \"pitcure\"}, \"image_url\": \"#{message.image_url}\", \"block_id\": \"image4\",\"alt_text\": \"pitcure here\"}]"
    end

    def schedule_blocks_text(message)
      "[{\"block_id\": \"#{message.id}\", \"type\": \"section\",\"text\": {\"type\": \"mrkdwn\", \"text\": \"#{message.message}\" }}]"
    end
  end
end
