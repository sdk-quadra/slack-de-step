# frozen_string_literal: true

module CryptBuilder
  extend ActiveSupport::Concern

  def encrypt_token(salt, oauth_bot_token)
    crypt = message_encryptor(salt)
    crypt.encrypt_and_sign(oauth_bot_token)
  end

  def decrypt_token(oauth_bot_token)
    salt = App.find_by(oauth_bot_token: oauth_bot_token).salt
    crypt = message_encryptor(salt)
    crypt.decrypt_and_verify(oauth_bot_token)
  end

  def token_salt
    len = message_key_len
    SecureRandom.hex(len)
  end

  private
    def message_encryptor(salt)
      len = message_key_len
      key = ActiveSupport::KeyGenerator.new("oauth_bot_token").generate_key(salt, len)
      ActiveSupport::MessageEncryptor.new(key)
    end

    def message_key_len
      ActiveSupport::MessageEncryptor.key_len
    end
end
