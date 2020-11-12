# frozen_string_literal: true

class Message < ApplicationRecord
  has_one :push_timing, dependent: :destroy
  belongs_to :channel
  accepts_nested_attributes_for :push_timing
  mount_uploader :image, ImageUploader

  validates :message, presence: true
end
