# SupportDesk - Ticket Management System

A minimal but solid customer support ticket management system built with Ruby on Rails (API mode), Vue 3, and PostgreSQL.

## Tech Stack

### Backend
- **Ruby**: 3.2.2
- **Rails**: 7.1.5 (API mode)
- **Database**: PostgreSQL 15
- **Authentication**: bcrypt (cookie-based sessions)
- **Authorization**: Pundit
- **Pagination**: Kaminari
- **Realtime**: Action Cable (WebSockets)
- **Testing**: RSpec

### Frontend
- **Vue**: 3.x
- **Build Tool**: Vite
- **State Management**: Pinia
- **Routing**: Vue Router
- **HTTP Client**: Axios
- **UI**: Minimal/clean (Tailwind optional later)

## Project Structure

```
vibecodingmasterclass/
├── app/                    # Rails application code
│   ├── controllers/        # API endpoints
│   ├── models/            # Database models
│   ├── channels/          # Action Cable channels (WebSockets)
│   ├── jobs/              # Background jobs
│   └── mailers/           # Email templates
├── config/                # Rails configuration
│   ├── initializers/
│   │   └── cors.rb        # CORS settings for frontend
│   ├── database.yml       # Database configuration
│   └── routes.rb          # API routes
├── db/                    # Database files
│   ├── migrate/           # Database migrations
│   └── seeds.rb           # Sample data
├── frontend/              # Vue 3 application
│   ├── src/
│   │   ├── components/    # Reusable Vue components
│   │   ├── views/         # Page components
│   │   ├── stores/        # Pinia state stores
│   │   ├── router/        # Vue Router config
│   │   └── main.js        # Vue app entry point
│   ├── package.json       # Frontend dependencies
│   └── vite.config.js     # Vite config (includes proxy to Rails)
├── bin/
│   ├── setup              # Initial setup script
│   └── dev                # Start both servers
├── Gemfile                # Ruby dependencies
├── Procfile.dev           # Development process manager
├── .env.example           # Environment variable template
└── README.md              # This file
```

## Prerequisites

Before you begin, ensure you have the following installed:

- **Ruby 3.2.2** (via rbenv)
- **Node.js** 18+ and npm
- **PostgreSQL 15**
- **Redis** (for Action Cable in production)
- **foreman** gem (for running Procfile.dev)

## Initial Setup

### 1. Clone or navigate to the project directory
```bash
cd /path/to/vibecodingmasterclass
```

### 2. Install backend dependencies
```bash
bundle install
```

### 3. Install frontend dependencies
```bash
cd frontend
npm install
cd ..
```

### 4. Set up environment variables
```bash
cp .env.example .env
# Edit .env if needed (database credentials, etc.)
```

### 5. Create and set up the database
```bash
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed  # (coming in Task 2 - will create sample users/tickets)
```

### 6. Start the development servers
```bash
bin/dev
```

This will start:
- **Rails API server** at `http://localhost:3000`
- **Vue dev server** at `http://localhost:5173`

## How It Works - The Development Setup

### CORS Configuration
The Rails API is configured to accept requests from the Vue frontend running on port 5173.

**File**: `config/initializers/cors.rb`
- **What it does**: Tells Rails to accept HTTP requests from http://localhost:5173
- **Why**: Without this, your browser would block API calls from the Vue app (security feature called Cross-Origin Resource Sharing)
- **credentials: true**: Allows cookies to be sent with requests (needed for session-based auth)

### Vite Proxy
The Vue frontend is configured to proxy API and WebSocket requests to the Rails backend.

**File**: `frontend/vite.config.js`
- **What it does**:
  - When your Vue app makes a request to `/api/*`, Vite forwards it to `http://localhost:3000/api/*`
  - When your Vue app connects to `/cable`, Vite forwards WebSocket to Rails Action Cable
- **Why**: This avoids CORS issues and makes development easier. In production, you'd use a reverse proxy (nginx) or deploy them together.

### Procfile.dev
Runs both servers concurrently during development.

**How to use**:
```bash
bin/dev  # Starts both Rails and Vue dev servers
```

**What's happening**:
1. The `foreman` gem reads `Procfile.dev`
2. It starts two processes:
   - `web`: Rails server on port 3000
   - `frontend`: Vite dev server on port 5173
3. Both run in the same terminal with colored output

**Alternative** (if you prefer separate terminals):
```bash
# Terminal 1 - Rails
bin/rails server

# Terminal 2 - Vue
cd frontend && npm run dev
```

## Key Files & What They Do

### Backend (Rails)

#### `Gemfile`
Lists all Ruby libraries (gems) the project needs:
- **bcrypt**: Encrypts passwords (used with `has_secure_password`)
- **rack-cors**: Handles cross-origin requests from the frontend
- **redis**: In-memory data store for Action Cable
- **pundit**: Authorization (who can do what)
- **kaminari**: Pagination (page through long lists of tickets)
- **rspec-rails**, **factory_bot_rails**, **faker**: Testing tools

#### `config/database.yml`
Database connection settings for PostgreSQL:
- Development database: `vibecodingmasterclass_development`
- Test database: `vibecodingmasterclass_test`
- Uses PostgreSQL instead of SQLite for production-grade features

#### `config/routes.rb`
Defines API endpoints (URLs) that the frontend can call.
Example:
```ruby
namespace :api do
  resources :tickets
  # Creates routes like:
  # GET    /api/tickets     (list all)
  # POST   /api/tickets     (create new)
  # GET    /api/tickets/:id (show one)
  # PATCH  /api/tickets/:id (update)
  # DELETE /api/tickets/:id (delete)
end
```

### Frontend (Vue)

#### `frontend/package.json`
Lists JavaScript dependencies:
- **vue**: The Vue framework
- **pinia**: State management (like Redux for React)
- **vue-router**: Client-side routing
- **axios**: Makes HTTP requests to the Rails API

#### `frontend/vite.config.js`
Vite configuration:
- **port 5173**: Vue dev server port
- **proxy /api**: Forwards API calls to Rails
- **proxy /cable**: Forwards WebSocket connections to Rails

#### `frontend/src/main.js`
Entry point of the Vue app. This is where we'll:
- Create the Vue app instance
- Register Pinia (state management)
- Register Vue Router
- Mount the app to the DOM

## Development Workflow

### Making Changes

1. **Backend changes** (models, controllers, etc.):
   - Edit files in `app/`
   - Rails auto-reloads in development
   - Refresh browser to see changes

2. **Database changes**:
   ```bash
   bin/rails generate migration AddFieldToTickets field:string
   bin/rails db:migrate
   ```

3. **Frontend changes**:
   - Edit files in `frontend/src/`
   - Vite hot-reloads instantly (no browser refresh needed!)

### Running Tests

```bash
# Backend (RSpec)
bundle exec rspec

# Frontend (when we add tests later)
cd frontend && npm test
```

## Common Commands

### Rails
```bash
# Create a new model
bin/rails generate model Ticket title:string status:string

# Create a new controller
bin/rails generate controller Api::Tickets

# Run migrations
bin/rails db:migrate

# Rollback last migration
bin/rails db:rollback

# Open Rails console (test code interactively)
bin/rails console

# Check routes
bin/rails routes
```

### Database
```bash
# Reset database (careful! deletes all data)
bin/rails db:reset

# Seed data
bin/rails db:seed
```

### Frontend
```bash
cd frontend

# Install a new package
npm install package-name

# Build for production
npm run build
```

## Troubleshooting

### Rails server won't start
- **Check PostgreSQL**: Is it running? `brew services list`
- **Start PostgreSQL**: `brew services start postgresql@15`
- **Database doesn't exist**: Run `bin/rails db:create`

### Frontend can't connect to API
- **Check CORS**: Is Rails running on port 3000?
- **Check proxy**: Is `vite.config.js` proxy pointing to `http://localhost:3000`?
- **Check browser console**: Look for CORS errors or network failures

### Port already in use
- **Rails (3000)**: Something else is running on port 3000
  ```bash
  lsof -ti:3000 | xargs kill -9
  ```
- **Vue (5173)**: Something else is running on port 5173
  ```bash
  lsof -ti:5173 | xargs kill -9
  ```

## Next Steps

This completes **Task 1: Project Setup**. The application structure is ready!

**Coming in Task 2**:
- User model with roles (admin, agent, customer)
- Ticket model with auto-generated ticket keys (SUP-000001)
- Comments model (public vs internal notes)
- Tags model (many-to-many with tickets)
- Database migrations and seed data
- Model validations and associations

**To verify the setup is working**, try running:
```bash
bin/dev
```

You should see both servers start. Open `http://localhost:5173` in your browser and you should see the default Vue welcome page.

## Architecture Decisions

### Why API mode Rails?
- **Clean separation**: Backend (Rails) handles data, frontend (Vue) handles UI
- **Flexibility**: Can swap frontend framework or add mobile apps later
- **Modern**: Industry standard for web apps

### Why cookie sessions instead of JWT?
- **Simpler**: No token management, expiry handling, refresh tokens
- **Secure**: HttpOnly cookies can't be stolen by JavaScript (XSS protection)
- **Good for web apps**: Works great when frontend and backend are on same domain
- **Note**: If you add a mobile app later, we can add token-based auth alongside sessions

### Why Pundit instead of CanCanCan?
- **Explicit**: Each authorization rule is clear and testable
- **Object-oriented**: Uses plain Ruby objects (policies)
- **Flexible**: Easy to customize per-model

### Why Kaminari instead of will_paginate?
- **Maintained**: Active development
- **Flexible**: Easy to customize page sizes, styles
- **Rails 7 compatible**: Works with latest Rails

## Resources

- [Rails Guides](https://guides.rubyonrails.org/)
- [Vue 3 Documentation](https://vuejs.org/)
- [Vite Documentation](https://vitejs.dev/)
- [Pinia Documentation](https://pinia.vuejs.org/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
