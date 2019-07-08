require 'rails_helper'

RSpec.feature 'View helpers', type: :helper do
  describe "#course_summary_label" do
    it "returns correct content" do
      expect(helper.course_summary_label('About course', "about_course")).to eq('<dt class="govuk-summary-list__key">About course</dt>')
    end

    context "with errors" do
      before do
        @provider = Provider.new(build(:provider).attributes)
        @course = Course.new(build(:course).attributes)
        @errors = { about_course: ['Something about the course'] }
      end

      it "returns correct content" do
        expect(helper.course_summary_label('About course', :about_course)).to eq("<dt class=\"govuk-summary-list__key app-course-parts__fields__label--error\"><span>About course</span><a class=\"govuk-link govuk-!-display-block\" href=\"/organisations/#{@provider.provider_code}/#{@course.recruitment_cycle_year}/courses/#{@course.course_code}/about#about_course_wrapper\">Something about the course</a></dt>")
      end
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

  describe '#course_manage_error_link' do
    before do
      @provider = Provider.new(build(:provider).attributes)
      @course = Course.new(build(:course).attributes)
    end

    it "returns correct content" do
      expect(helper.course_manage_error_link('about_course', 'Something about the course'))
        .to eq("<a class=\"govuk-link govuk-!-display-block\" href=\"/organisations/#{@provider.provider_code}/#{@course.recruitment_cycle_year}/courses/#{@course.course_code}/about#about_course_wrapper\">Something about the course</a>")
    end
  end
end
