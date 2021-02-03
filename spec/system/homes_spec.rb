# frozen_string_literal: true

require "rails_helper"

RSpec.describe "messages", type: :system do
  it "TOPからプライバシ・ポリシーページを訪問できる事" do
    visit root_path
    click_link "プライバシー・ポリシー"
    expect(page).to have_content("プライバシー・ポリシー")
  end
end
