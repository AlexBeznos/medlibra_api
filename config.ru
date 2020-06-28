# frozen_string_literal: true

require "appsignal"                           # Load AppSignal

Appsignal.config = Appsignal::Config.new(
  File.expand_path(__dir__),                  # Application root path
  "production", # Application environment
)

Appsignal.start                               # Start the AppSignal integration
Appsignal.start_logger                        # Start logger

require_relative "system/boot"
run Medlibra::Web.freeze.app
