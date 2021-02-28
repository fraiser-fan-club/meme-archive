class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create

  def create
    puts auth_hash
    redirect_to '/'
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end
