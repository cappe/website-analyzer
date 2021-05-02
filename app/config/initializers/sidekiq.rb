require 'sidekiq/web'

Sidekiq::Web.set :session_secret, Rails.application.credentials[:secret_key_base]

sidekiq_username = Rails.application.credentials.dig(:sidekiq, :username)
sidekiq_password = Rails.application.credentials.dig(:sidekiq, :password)

Sidekiq::Web.use Rack::Auth::Basic do |username, password|
  ActiveSupport::SecurityUtils.secure_compare(username, sidekiq_username) &
    ActiveSupport::SecurityUtils.secure_compare(password, sidekiq_password)
end unless Rails.env.development?
