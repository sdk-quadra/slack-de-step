# frozen_string_literal: true

class ImageUploader < CarrierWave::Uploader::Base
  storage :fog

  def store_dir
    "#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_whitelist
    %w[jpg jpeg gif png]
  end

  def filename
    original_filename
  end

  def size_range
    0..2.megabytes
  end
end
