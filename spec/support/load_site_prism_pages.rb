Dir['./spec/site_prism/**/*.rb'].each do |file|
  if require file
    # For each file that gets required automatically generate the object name
    # and class name and create a method to do lazy-instantiation on the object
    # class.

    if (match = file.match(%r{
            ^\./spec/site_prism/
            (?<class>
              page_objects/
              (?<type> (?: page | section)) /
              (?<name> .*)
            )
            \.rb$
          }x))
      class_name  = match['class'].camelize
      object_name = match['name'].tr('/', '_')
      object_type = match['type']
      full_name   = "#{object_name}_#{object_type}"

      define_method full_name do
        PageObjects::Base.objects[full_name] ||=
          class_name.constantize.__send__ :new
      end
    end
  end
end
