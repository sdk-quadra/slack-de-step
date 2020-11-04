class ImageUploader < CarrierWave::Uploader::Base

  storage :fog

  def store_dir
    "#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_whitelist
    %w(jpg jpeg gif png)
  end

  def filename
    original_filename if original_filename
  end
end
