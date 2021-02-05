# frozen_string_literal: true

class Contact < ApplicationRecord
  validates :email, presence: true
  validates :message, presence: true
end
