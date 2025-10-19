# Configure session storage for API mode
Rails.application.config.session_store :cookie_store,
  key: '_supportdesk_session',
  same_site: :none,  # Required for cross-domain cookies (frontend on different domain)
  httponly: true,
  secure: Rails.env.production?,  # Use secure cookies in production (HTTPS)
  domain: :all  # Allow cookies to be sent from any subdomain
