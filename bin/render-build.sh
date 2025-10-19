#!/usr/bin/env bash
# exit on error
set -o errexit

# Configure bundler to skip development and test groups
bundle config set --local deployment 'true'
bundle config set --local without 'development test'

bundle install
bundle exec rake db:migrate
bundle exec rake db:seed
