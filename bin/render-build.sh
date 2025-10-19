#!/usr/bin/env bash
# exit on error
set -o errexit

# Install system dependencies for gems with native extensions
apt-get update -qq && apt-get install -y libyaml-dev

# Install only production dependencies
bundle config set --local without 'development test'
bundle install --jobs 4 --retry 3

bundle exec rake db:migrate
bundle exec rake db:seed
