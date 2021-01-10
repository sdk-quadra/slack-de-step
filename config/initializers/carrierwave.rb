# frozen_string_literal: true

CarrierWave.configure do |config|
  config.fog_credentials = {
    provider: "AWS",
    aws_access_key_id: ENV["AWS_ACCESS_KEY"],
    aws_secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
    region: "ap-northeast-1"
  }
  config.fog_directory = ENV["AWS_BUCKET"]
  config.asset_host = "https://#{ENV["AWS_BUCKET"]}.s3.amazonaws.com"
  config.cache_storage = :fog
end
