# This file is used by Rack-based servers to start the application.

require_relative "config/environment"

# Middleware stack for RSpec Rack-based requests:
# - Rack::Session::Cookie is added only for API requests to ensure API::V1::OrdersController#place_order behaves correctly
#   when session state is involved (even if not explicitly used in current implementation).
# - Use file-based session store for persistence during tests instead of in-memory (default).
# - Keep Rack::Cors for Cross-Origin Resource Sharing.

Rails.application.configure do
  config.middleware.use Rack::Session::Cookie,
    key: '_restaurant_platform_session',
    same_site: :lax,
    secure: Rails.env.production?,
    path: '/',
    expire_after: 1.year,
    cookie_only: true
end

run Rails.application
Rails.application.load_server
