source "https://rubygems.org"

ruby "2.7.0"

gem "rake"

# Web framework
gem "dry-web-roda"
gem "dry-system"
gem "dry-web"
gem "puma"
gem "rack_csrf"

gem "rack", ">= 2.0"

# Database persistence
gem "pg"
gem "rom", "~> 5.1"
gem "rom-sql", "~> 3.1"
gem "sequel_postgresql_triggers"

# Application dependencies
gem "dry-matcher"
gem "dry-monads"
gem "dry-struct"
gem "dry-types"
gem "dry-validation"

group :development, :test do
  gem "pry-byebug", platform: :mri
end

group :development do
  gem "rerun"
end

group :test do
  gem "capybara"
  gem "capybara-screenshot"
  gem "database_cleaner"
  gem "poltergeist"
  gem "rspec"
  gem "rom-factory", "~> 0.10"
end
