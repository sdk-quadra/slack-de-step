module CurlBuilder
  extend ActiveSupport::Concern
  def curl_build(base_url:, method: "GET", params: {}, headers: {}, body_filename: nil, verbose: true, silent: true, options: "")
    url = base_url
    url += "?" + URI.encode_www_form(params) unless params.empty?
    cmd = "curl '#{url}'"
    cmd += " -d '@#{body_filename}'" if body_filename
    cmd += " " + headers.map { |k, v| "-H '#{k}: #{v}'" }.join(" ") + " " unless headers.empty?
    cmd += " -s " if silent
    cmd
  end

  def curl_exec(*args, **kwargs)
    cmd = curl_build(*args, **kwargs)
    Open3.capture3(cmd)
  end
end
