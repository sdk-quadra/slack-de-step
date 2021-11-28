# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.6.3"

gem "rails", "~> 6.1.3"
gem "pg"
gem "puma", "~> 4.1"
gem "sass-rails", ">= 6"
gem "webpacker", "~> 4"
gem "turbolinks", "~> 5"
# gem "jbuilder", "~> 2.7"
gem "bootsnap", ">= 1.4.2", require: false

gem "carrierwave"
gem "fog-aws"
gem "redis-namespace"
gem "sidekiq"
gem "rails-i18n"
gem "slim-rails"
gem "rinku"
gem "parser", "~> 2.6.3.0"

group :development, :test do
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  gem "rubocop"
  gem "rubocop-performance"
  gem "rubocop-rails"
  gem "awesome_print"
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "slim_lint"
end

group :development do
  gem "listen", "~> 3.2"
  gem "web-console", ">= 3.3.0"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
end

group :test do
  gem "capybara", ">= 2.15"
  gem "selenium-webdriver"
  gem "webdrivers"
end

gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]
