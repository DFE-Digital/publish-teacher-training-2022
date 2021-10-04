require "rails_helper"

describe Settings do
  settings = YAML.load_file(Rails.root.join("config/settings.yml")).with_indifferent_access

  subject do
    settings
  end

  describe "settings.teacher_training_api" do
    subject do
      settings[:teacher_training_api]
    end

    its(%w[algorithm]) { should_not be_blank }
    its(%w[secret]) { should_not be_blank }
    its(%w[base_url]) { should_not be_blank }
    its(%w[issuer]) { should_not be_blank }
    its(%w[audience]) { should_not be_blank }
    its(%w[subject]) { should_not be_blank }
  end

  its(%w[current_cycle]) { should eq 2022 }

  describe "settings.authentication" do
    subject do
      settings[:authentication]
    end

    its(%w[mode]) { should eq "dfe_signin" }
  end

  describe "settings.authentication.basic_auth" do
    subject do
      settings[:authentication][:basic_auth]
    end

    its(%w[disabled]) { should be_falsey }
    its(%w[username]) { should_not be_blank }
    its(%w[password_digest]) { should_not be_blank }
  end
end
