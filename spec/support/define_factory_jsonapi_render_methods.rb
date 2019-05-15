FactoryBot.define do
  # This defines an after build callback that goes on ALL factories.
  after :build do |record|
    # This defines an instance method called to_jsonapi on the object we just
    # created with the factory.
    record.define_singleton_method(:to_jsonapi) do
      # Create a string that holds the name of the class, for example
      # "UserSerializer"
      serializer_class = "#{record.class}Serializer"

      renderer = JSONAPI::Serializable::Renderer.new
      renderer.render(
        record,
        class: {
          # This tells the renderer what serializers to use. The key is going
          # to be the name of the class as a symbol, and the value is the
          # serializer class.
          #
          # For example: User: UserSerializer
          record.class.name.to_sym => serializer_class.constantize
        }
      )
    end
  end
end
