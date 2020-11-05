require "rails_helper"

describe Settings do
  describe "authentication" do
    subject do
      YAML.load_file(Rails.root.join("config/settings.yml"))
    end

    its(%w[current_cycle]) { should eq 2021 }
  end
end
