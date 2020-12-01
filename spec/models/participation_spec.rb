require "rails_helper"

RSpec.describe Message, type: :model do
  before do
    @user = FactoryBot.create(:user)
    @workspace = FactoryBot.create(:workspace)
    @possession = FactoryBot.create(:possession, user_id: @user.id, workspace_id: @workspace.id)
    @app = FactoryBot.create(:app, workspace_id: @workspace.id)
    @channel = FactoryBot.create(:channel, app_id: @app.id)
  end

  it "メッセージに画像がなくても登録できる事" do
    message = Message.new(
      channel_id: @channel.id,
      message: "メッセージ登録テスト"
    )
    expect(message).to be_valid
  end

  it "channel_idがなければ登録できない事" do
    message = Message.new(
      message: "メッセージ登録テスト"
    )
    expect(message).to_not be_valid
  end

end
