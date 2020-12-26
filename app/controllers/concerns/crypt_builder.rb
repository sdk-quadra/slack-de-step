# frozen_string_literal: true

module CryptBuilder
  extend ActiveSupport::Concern

  def encrypt_token(oauth_bot_token)
    crypt = message_encryptor
    encrypted_token = crypt.encrypt_and_sign(oauth_bot_token)
    encrypted_token
  end

  def decrypt_token(oauth_bot_token)
    crypt = message_encryptor
    decrypted_token = crypt.decrypt_and_verify(oauth_bot_token)
    decrypted_token
  end

  def message_encryptor
    len   = ActiveSupport::MessageEncryptor.key_len
    key   = ActiveSupport::KeyGenerator.new("oauth_bot_token").generate_key(ENV["SALTED_KEY"], len)
    crypt = ActiveSupport::MessageEncryptor.new(key)
    crypt
  end
end
