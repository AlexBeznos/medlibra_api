# frozen_string_literal: true

Medlibra::Container.boot :monitor, namespace: true do |system|
  init do
    require "dry/monitor/sql/logger"
    require "sentry-raven"
    require "newrelic_rpm"
  end

  start do
    use :settings

    logger.info!

    notifications.register_event(:sql)
    Dry::Monitor::SQL::Logger.new(logger).subscribe(notifications)

    Raven.configure do |config|
      config.dsn = system[:settings].sentry_dsn
    end

    register "sentry", Raven

    system["rack_monitor"].on(:error) do |params|
      Raven.user_context(uid: params[:uid])
      Raven.capture_exception(params[:exception])
    end
  end
end
