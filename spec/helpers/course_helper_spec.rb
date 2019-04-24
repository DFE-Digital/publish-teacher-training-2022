require 'rails_helper'

RSpec.feature 'View helpers', type: :helper do
  describe "#course_has_unpublished_changes" do
    it "returns true when course has the right content_status" do
      expect(helper.course_has_unpublished_changes(build(:course, content_status: 'published_with_unpublished_changes'))).to eq(true)
    end

    it "returns false when course has a different content_status" do
      expect(helper.course_has_unpublished_changes(build(:course, content_status: 'foo'))).to eq(false)
    end
  end

  describe "#course_content_tag_content" do
    it "returns correct content" do
      expect(helper.course_content_tag_content(build(:course, content_status: 'published'))).to eq('Published')
      expect(helper.course_content_tag_content(build(:course, content_status: 'empty'))).to eq('Empty')
      expect(helper.course_content_tag_content(build(:course, content_status: 'draft'))).to eq('Draft')
      expect(helper.course_content_tag_content(build(:course, content_status: 'published_with_unpublished_changes'))).to eq('Published&nbsp;*')
    end
  end

  describe "#course_content_tag_css_class" do
    it "returns correct css_class" do
      expect(helper.course_content_tag_css_class(build(:course, content_status: 'published'))).to eq('phase-tag--published')
      expect(helper.course_content_tag_css_class(build(:course, content_status: 'empty'))).to eq('phase-tag--no-content')
      expect(helper.course_content_tag_css_class(build(:course, content_status: 'draft'))).to eq('phase-tag--draft')
      expect(helper.course_content_tag_css_class(build(:course, content_status: 'published_with_unpublished_changes'))).to eq('phase-tag--published')
    end
  end

  describe "#course_ucas_status" do
    it "returns correct content" do
      expect(helper.course_ucas_status(build(:course, ucas_status: 'running'))).to eq('Running')
      expect(helper.course_ucas_status(build(:course, ucas_status: 'new'))).to eq('New – not yet running')
      expect(helper.course_ucas_status(build(:course, ucas_status: 'not_running'))).to eq('Not running')
    end
  end

  describe "#course_apprenticeship" do
    it "returns correct content" do
      expect(helper.course_apprenticeship(build(:course, funding: 'apprenticeship'))).to eq('Yes')
      expect(helper.course_apprenticeship(build(:course, funding: 'fee'))).to eq('No')
    end
  end

  describe "#course_funding" do
    it "returns correct content" do
      expect(helper.course_funding(build(:course, funding: 'salary'))).to eq('Salaried')
      expect(helper.course_funding(build(:course, funding: 'apprenticeship'))).to eq('Teaching apprenticeship (with salary)')
      expect(helper.course_funding(build(:course, funding: 'fee'))).to eq('Fee paying (no salary)')
    end
  end

  describe "#course_applications_open" do
    it "returns correct content" do
      expect(helper.course_applications_open(build(:course, applications_open_from: '2019-01-01T00:00:00Z'))).to eq('1 January 2019')
    end
  end

  describe "#course_send" do
    it "returns correct content" do
      expect(helper.course_send(build(:course, is_send?: true))).to eq('Yes')
      expect(helper.course_send(build(:course, is_send?: false))).to eq('No')
    end
  end

  describe "#course_length" do
    it "returns correct content" do
      expect(helper.course_length(build(:course, course_length: 'OneYear'))).to eq('1 year')
      expect(helper.course_length(build(:course, course_length: 'TwoYears'))).to eq('Up to 2 years')
      expect(helper.course_length(build(:course, course_length: 'Some other length'))).to eq('Some other length')
    end
  end

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
