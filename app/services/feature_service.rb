module FeatureService
  class << self
    def require(feature_name)
      unless Settings.features[feature_name]
        raise "Feature #{feature_name} is disabled"
      end

      true
    end

    def enabled?(feature_name)
      Settings.features[feature_name]
    end
  end
end
