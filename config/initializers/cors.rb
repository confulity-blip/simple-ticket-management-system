# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin Ajax requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Allow requests from Vue dev server and production frontend
    origins_list = [
      "http://localhost:5173",
      "http://127.0.0.1:5173"
    ]

    # Add production frontend URL from environment variable
    origins_list << ENV['FRONTEND_URL'] if ENV['FRONTEND_URL'].present?

    origins(*origins_list)

    resource "*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true
  end
end
