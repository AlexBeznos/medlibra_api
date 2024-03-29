# frozen_string_literal: true

source "https://rubygems.org"

ruby "2.7.1"

gem "rake"

# Web framework
gem "dry-system"
gem "dry-web"
gem "dry-web-roda"
gem "puma"
gem "rack_csrf"

gem "rack", ">= 2.0"

# Database persistence
gem "pg"
gem "rom", "~> 5.2"
gem "rom-sql", "~> 3.1"
gem "sequel_postgresql_triggers"

# Background jobs
gem "sidekiq"

# Application dependencies
gem "concurrent-ruby"
gem "curb"
gem "dry-matcher"
gem "dry-monads"
gem "dry-struct"
gem "dry-types"
gem "dry-validation"
gem "jwt"
gem "oj"

# Caching
gem "redis"

# Monitoring
gem "appsignal"
gem "sentry-raven"

group :development, :test do
  gem "pry-byebug", platform: :mri
  gem "rubocop"
end

group :development do
  gem "rerun"
  gem "ruby-progressbar"
end

group :test do
  gem "codecov", require: false
  gem "database_cleaner"
  gem "rack-test"
  gem "rom-factory", "~> 0.10"
  gem "rspec"
  gem "rspec-sidekiq"
  gem "simplecov", require: false
  gem "webmock"
end
