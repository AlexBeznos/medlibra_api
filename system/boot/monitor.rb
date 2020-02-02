# frozen_string_literal: true

Medlibra::Container.boot :monitor do
  init do
    require "dry/monitor/sql/logger"
  end

  start do
    notifications.register_event(:sql)
    Dry::Monitor::SQL::Logger.new(logger).subscribe(notifications)
  end
end
