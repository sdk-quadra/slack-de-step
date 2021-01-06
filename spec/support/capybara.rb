# frozen_string_literal: true

require "selenium-webdriver"
require "capybara/rspec"

Capybara.register_driver :chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  #
  # options.add_argument('disable-notifications')
  # options.add_argument('disable-translate')
  # options.add_argument('disable-extensions')
  # options.add_argument('disable-infobars')
  options.add_argument("window-size=1280,960")

  options.add_argument("--disable-dev-shm-usage")


  # ブラウザーを起動する
  Capybara::Selenium::Driver.new(
    app,
      browser: :chrome,
      options: options)
end
