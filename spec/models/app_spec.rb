# frozen_string_literal: true

require "rails_helper"

RSpec.describe Message, type: :model do
  before do
    @workspace = FactoryBot.create(:workspace)
    @app = FactoryBot.create(:app, workspace_id: @workspace.id)
  end

  it "appを登録できる事" do
    expect(@app).to be_valid
  end

  it "app_idなしではchannelを登録できない事" do
    app = Channel.new(
      name: "test channel"
    )
    expect(app).to_not be_valid
  end
end
