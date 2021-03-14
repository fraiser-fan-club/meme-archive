class User < ApplicationRecord
  def self.find_or_create_from_auth_hash(auth_hash) 
    user = User.find_by(uid: auth_hash[:uid])
    if user.nil?
      user = User.create(
        uid: auth_hash[:uid],
        provider: auth_hash[:provider],
        name: auth_hash[:info][:name],
        image: auth_hash[:info][:image]
      )
    end
    user
  end
end
