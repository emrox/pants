class UserPinger
  include BackgroundJob

  def perform(user_url, body = {})
    HTTParty.post(URI.join(user_url.with_http, '/ping'), body: body)
  end
end
