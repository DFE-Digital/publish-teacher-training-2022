FactoryBot.factories.each do |factory|
  next unless factory.name.in? []

  # Create a string that holds the name of the class, for example
  # "UserSerializer"
  serializer_class_name = "#{factory.name.capitalize}Serializer"

  # Create a new class (of type Class) and make it inherit from the JSONAPI
  # serializer resource. Everything in the block is related to the serializer.
  #
  # We set the serializer type to the plural of the factory name, for example
  # "users".
  # We set the attributes to render out to the attributes we define in the
  # factory.
  serializer_class      = Class.new(JSONAPI::Serializable::Resource) do
    type(factory.name.to_s.pluralize)
    attributes(*FactoryBot.attributes_for(factory.name).keys)
  end

  # Create a new constant with the class name and make it point to the class
  # we created. For example "UserSerializer", and it would point to the class
  # we created.
  Object.const_set(serializer_class_name, serializer_class)
end
