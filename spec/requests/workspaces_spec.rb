# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Workspaces", type: :request do

  it "workspace一覧に訪問できる事" do
    get workspaces_path
    expect(response).to have_http_status(200)
  end

end
