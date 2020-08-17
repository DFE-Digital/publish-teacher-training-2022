require "rails_helper"

RSpec.describe CourseLevelComponent, type: :component do
  let(:provider) { build(:provider) }
  let(:course) { build(:course, provider: provider, level: "further_education") }

  it "shows the course level" do
    result = render_inline(CourseLevelComponent.new(course: course)).to_html
    expect(result).to include("Further education")
  end

  it "does not show the change link" do
    result = render_inline(CourseLevelComponent.new(course: course)).to_html
    expect(result).to_not include("Change")
  end

  context "when level is changeable" do
    it "shows the change link" do
      result = render_inline(CourseLevelComponent.new(course: course, changeable: true)).to_html
      expect(result).to include("Change")
    end
  end
end
