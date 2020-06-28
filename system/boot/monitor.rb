# frozen_string_literal: true

Medlibra::Container.boot :monitor, namespace: true do |system|
  init do
    require "dry/monitor/sql/logger"
    require "appsignal"
    require "sentry-raven"
  end

  start do
    use :settings

    if ENV["HEROKU_APP_NAME"] == "medlibra-stage"
      logger.info!
      logger.instance_variable_set(:@logdev, STDOUT)
    end

    notifications.register_event(:sql)
    Dry::Monitor::SQL::Logger.new(logger).subscribe(notifications)

    Raven.configure do |config|
      config.dsn = system[:settings].sentry_dsn
    end

    register "sentry", Raven
    register "appsignal", Appsignal

    system["rack_monitor"].on(:error) do |params|
      Raven.user_context(uid: params[:uid])
      Raven.capture_exception(params[:exception])
    end
  end
end
