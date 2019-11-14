require "rails_helper"

describe UserDecorator do
  let(:user) { build(:user, first_name: "Werner", last_name: "Schrodinger") }
  let(:decorated_user) { user.decorate }

  describe "#full_name" do
    it "provides the full name" do
      expect(decorated_user.full_name).to eq("Werner Schrodinger")
    end
  end
end
