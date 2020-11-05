# frozen_string_literal: true

class HomesController < ApplicationController
  skip_before_action :check_logined

  def index
  end
end
