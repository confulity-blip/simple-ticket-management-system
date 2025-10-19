# Configure session storage for API mode
Rails.application.config.session_store :cookie_store,
  key: '_supportdesk_session',
  same_site: :none,  # Required for cross-domain cookies (frontend on different domain)
  httponly: true,
  secure: true  # Required when same_site is :none
