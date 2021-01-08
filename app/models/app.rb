# frozen_string_literal: true

class App < ApplicationRecord
  belongs_to :workspace
  has_many :channels, dependent: :destroy
  has_many :companions, dependent: :destroy

  extend CryptBuilder

  def self.create_app(auth, workspace)
    oauth_bot_token = auth["access_token"]
    salt = token_salt
    bot_user_id = auth["bot_user_id"]

    encrypt_token = encrypt_token(salt, oauth_bot_token)

    # workspace_idがすでにあれば、更新する。bot_tokenが変わった場合を想定
    app = App.find_or_initialize_by(workspace_id: workspace.id)
    app.update_attributes(
      oauth_bot_token: encrypt_token,
      salt: salt,
      bot_user_id: bot_user_id
    )
    app
  end
end
