class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create

  def new
  end

  def create
    if teamloser_guild?
      user = User.find_or_create_from_auth_hash(auth_hash)
      reset_session
      session[:user_id] = user.id
    else
      puts 'Fail'
    end
    redirect_to '/'
  end

  private
  def auth_hash
    request.env['omniauth.auth']
  end

  def teamloser_guild?
    uri = URI('https://discord.com/api/v8/users/@me/guilds')
    req = Net::HTTP::Get.new(uri)
    req['Authorization'] = "Bearer #{auth_hash[:credentials][:token]}"
    res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) {|http|
      http.request(req)
    }
    JSON.parse(res.body).any? {|guild| guild["id"] == ENV['DISCORD_GUILD_ID']}
  end
end
