# frozen_string_literal: true

require "rails_helper"

RSpec.describe "workspaces", type: :system do
  before do
    driven_by(:rack_test)
  end

  before do
    @user = FactoryBot.create(:user)
  end

  it "workspace一覧を表示する事" do
    page.set_rack_session(user_id: @user.id)
    visit workspaces_path
    expect(page).to have_content "ワークスペースを選択"
  end
end
