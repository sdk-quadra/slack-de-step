# frozen_string_literal: true

class CurlBuilder
  def build(base_url:, method: "GET", params: {}, headers: {}, body_filename: nil, verbose: true, silent: true, options: "")
    url = base_url
    url += "?" + URI.encode_www_form(params) unless params.empty?
    cmd = "curl '#{url}'"
    cmd += " -d '@#{body_filename}'" if body_filename
    cmd += " " + headers.map { |k, v| "-H '#{k}: #{v}'" }.join(" ") + " " unless headers.empty?
    # cmd += " -v " if verbose
    cmd += " -s " if silent
    # cmd += options
    cmd
  end

  def exec(*args, **kwargs)
    cmd = build(*args, **kwargs)
    o, e, s = Open3.capture3(cmd)
  end
end

class User < ApplicationRecord
  has_one :workspace

  def self.find_or_create_form_auth(auth)
    provider = auth[:provider]
    uid = auth[:uid]
    name = auth[:info][:name]
    email = auth[:info][:email]

    user = self.find_or_create_by!(provider: provider, uid: uid) do |user|
      user.name = name
      user.email = email
    end
    user
  end
end
