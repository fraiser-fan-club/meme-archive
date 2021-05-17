Rails.application.config.middleware.use OmniAuth::Builder do
  provider :discord,
           Rails.application.credentials.dig(
             :discord,
             ENV['DISCORD_APP'].to_sym,
             :client_id,
           ),
           Rails.application.credentials.dig(
             :discord,
             ENV['DISCORD_APP'].to_sym,
             :client_secret,
           ),
           scope: 'identify guilds'
end
