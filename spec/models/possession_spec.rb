# frozen_string_literal: true

require "rails_helper"

RSpec.describe Message, type: :model do
  before do
    @user = FactoryBot.create(:user)
    @workspace = FactoryBot.create(:workspace)
    @possession = FactoryBot.create(:possession, user_id: @user.id, workspace_id: @workspace.id)
  end

  it "possessionを登録できる事" do
    expect(@possession).to be_valid
  end

  it "user_idなしではpossessionを登録できない事" do
    possession = Possession.new(
      workspace_id: @workspace.id
    )
    expect(possession).to_not be_valid
  end

  it "workspace_idなしではpossessionを登録できない事" do
    possession = Possession.new(
      user_id: @user.id
    )
    expect(possession).to_not be_valid
  end
end
