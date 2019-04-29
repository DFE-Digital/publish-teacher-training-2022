require 'rails_helper'

RSpec.feature 'View helpers', type: :helper do
  describe "#course_summary_label" do
    it "returns correct content" do
      expect(helper.course_summary_label('About course')).to eq('<dt class="govuk-summary-list__key">About course</dt>')
    end
  end

  describe "#course_summary_value" do
    it "returns the value" do
      expect(helper.course_summary_value('Something about the course', 'about'))
        .to eq('<dd class="govuk-summary-list__value govuk-summary-list__value--truncate" data-qa="course__about">Something about the course</dd>')
    end

    it "returns 'empty' when value is empty" do
      expect(helper.course_summary_value('', 'about'))
        .to eq('<dd class="govuk-summary-list__value govuk-summary-list__value--truncate course-parts__fields__value--empty" data-qa="course__about">Empty</dd>')
    end
  end

  describe "#course_summary_item" do
    it "returns correct content" do
      expect(helper.course_summary_item('About course', 'Something about the course', 'about'))
        .to eq('<div class="govuk-summary-list__row"><dt class="govuk-summary-list__key">About course</dt><dd class="govuk-summary-list__value govuk-summary-list__value--truncate" data-qa="course__about">Something about the course</dd></div>')
    end
  end
end
