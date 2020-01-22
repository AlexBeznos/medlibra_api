class Medlibra::Web
  route do |r|
    r.on "v1" do
      r.on "users" do
        r.post do 
          r.resolve "transactions.users.create" do |create|
            result = create.(params: r.params)

            if result.success?
              r.halt(200)
            else
              r.halt(422, { errors: result.failure })
            end
          end
        end
      end
    end
  end
end
