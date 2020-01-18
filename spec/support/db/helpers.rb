module Test
  module DatabaseHelpers
    module_function

    def rom
      Medlibra::Container["persistence.rom"]
    end

    def db
      Medlibra::Container["persistence.db"]
    end
  end
end
