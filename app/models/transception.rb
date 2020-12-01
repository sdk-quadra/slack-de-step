# frozen_string_literal: true

class Transception < ApplicationRecord
  belongs_to :message

  validates :conversation_id, presence: true
end
