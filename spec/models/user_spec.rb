require "rails_helper"

RSpec.describe User, type: :model do
  before do
    @user = FactoryBot.create(:user)
    @workspace = FactoryBot.create(:workspace)
    @possession = FactoryBot.create(:possession, user_id: @user.id, workspace_id: @workspace.id)
    @app = FactoryBot.create(:app, workspace_id: @workspace.id)
    @channel = FactoryBot.create(:channel, app_id: @app.id)
  end

  it "user登録できる事" do
    expect(@user).to be_valid
  end
end
