# frozen_string_literal: true

Medlibra::Container.boot :middlewares do |system|
  start do
    use :utils

    inflector = system["utils.inflector"]

    Dir["lib/medlibra/middlewares/**/*.rb"].each do |file|
      path = file.gsub(%r{lib/}, "")
      require path

      namespace = File.path(path).gsub(/\.rb/, "")
      klass = inflector.constantize(inflector.camelize(namespace))
      key = namespace.tr("/", ".").gsub(/medlibra\./, "")

      register key, klass
    end
  end
end
