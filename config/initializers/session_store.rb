# Configure session storage for API mode
Rails.application.config.session_store :cookie_store,
  key: '_supportdesk_session',
  same_site: :lax,
  httponly: true,
  secure: Rails.env.production?  # Use secure cookies in production (HTTPS)
