# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  before do
    @user = FactoryBot.create(:user)
  end

  it "userを登録できる事" do
    expect(@user).to be_valid
  end

  it "emailなしではuserを登録できない事" do
    user = User.new(
      email: "slackdestep@gmail.com"
    )
    expect(user).to_not be_valid
  end

  it "nameなしではuserを登録できない事" do
    user = User.new(
      name: "slackdestep"
    )
    expect(user).to_not be_valid
  end
end
