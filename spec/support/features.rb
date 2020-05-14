RSpec.configure do |configure|
  # Allow examples to be tagged with "feature :some_feature". This will turn that
  # feature just for the duration of that test.
  configure.around :each do |example|
    original_features = {}

    example.metadata.keys.grep(/^feature_.*/) do |metadata_key|
      feature = metadata_key.to_s.delete_prefix("feature_")

      if Settings.features.key? feature
        original_features[feature] = Settings.features[feature]
      end

      Settings.features[feature] = example.metadata[metadata_key]
    end

    example.run

    Array[*example.metadata[:feature]].each do |feature|
      if original_features.key? feature
        Settings.features[feature] = original_features[feature]
      end
    end
  end
end
