# frozen_string_literal: true

source "https://rubygems.org"

ruby "2.7.0"

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
gem "rom", "~> 5.1"
gem "rom-sql", "~> 3.1"
gem "sequel_postgresql_triggers"

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

group :development, :test do
  gem "pry-byebug", platform: :mri
  gem "rubocop"
end

group :development do
  gem "rerun"
end

group :test do
  gem "database_cleaner"
  gem "rack-test"
  gem "rom-factory", "~> 0.10"
  gem "rspec"
  gem "webmock"
end
