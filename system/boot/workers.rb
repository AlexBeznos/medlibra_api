# frozen_string_literal: true

Medlibra::Container.boot :workers do |system|
  init do
    require "sidekiq"
  end

  start do
    use :utils

    inflector = system["utils.inflector"]

    Sidekiq.configure_server do |config|
      config.redis = { url: system[:settings].redis_url }
    end

    Sidekiq.configure_client do |config|
      config.redis = { url: system[:settings].redis_url }
    end

    Dir["lib/medlibra/workers/**/*.rb"].each do |file_path|
      file = file_path.gsub(%r{lib/}, "")
      require file

      namespace = File.path(file).gsub(/\.rb/, "")
      klass = inflector.constantize(inflector.camelize(namespace))
      key = namespace.tr("/", ".").gsub(/medlibra\./, "")

      register key, klass
    end
  end
end
