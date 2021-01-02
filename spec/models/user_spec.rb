# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  before do
    @user = FactoryBot.create(:user)
  end

  it "userを登録できる事" do
    expect(@user).to be_valid
  end
end
