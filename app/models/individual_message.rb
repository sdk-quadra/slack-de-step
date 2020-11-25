# frozen_string_literal: true

class IndividualMessage < ApplicationRecord
  belongs_to :message
  belongs_to :companion
end
