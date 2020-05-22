# frozen_string_literal: true

Medlibra::Container.boot :monitor do |system|
  init do
    require "dry/monitor/sql/logger"
  end

  start do
    notifications.register_event(:sql)
    Dry::Monitor::SQL::Logger.new(logger).subscribe(notifications)

    use :utils

    system["rack_monitor"].on(:error) do |params|
      system["utils.sentry"].user_context(uid: params[:uid])
      system["utils.sentry"].capture_exception(params[:exception])
    end
  end
end
