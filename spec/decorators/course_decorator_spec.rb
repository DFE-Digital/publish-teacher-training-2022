require 'rails_helper'

describe CourseDecorator do
  let(:provider) { jsonapi(:provider, accredited_body?: false) }
  let(:course_jsonapi) {
    jsonapi(:course,
            course_code: 'A1',
            name: 'Mathematics',
            qualifications: %w[qts pgce],
            study_mode: 'full_time',
            start_date: Time.new(2019),
            site_statuses: [site_status],
            provider: provider,
            accrediting_provider: provider,
            course_length: 'OneYear',
            open_for_applications?: true,
            last_published_at: '2019-03-05T14:42:34Z').to_resource
  }
  let(:site) { jsonapi(:site) }
  let(:site_status) do
    jsonapi(:site_status, :full_time_and_part_time, site: site)
  end

  let(:course) { course_jsonapi.decorate }

  it "returns formatted last_published_at" do
    expect(course.formatted_last_published_at).to eq('5 March 2019')
  end

  it "returns formatted start_date" do
    expect(course.formatted_start_date).to eq('January 2019')
  end

  it "returns formatted applications_open_from date" do
    expect(course.formatted_applications_open).to eq('1 January 2019')
  end

  it "returns the course name and code in brackets" do
    expect(course.name_and_code).to eq('Mathematics (A1)')
  end

  it "returns a list of subjects in alphabetical order" do
    expect(course.sorted_subjects).to eq('English<br>English with Primary')
  end

  it "returns if applications are open or closed" do
    expect(course.applications).to eq('Open')
  end

  it "returns if course is an apprenticeship" do
    expect(course.apprenticeship?).to eq('No')
  end

  it "returns if course is SEND?" do
    expect(course.is_send).to eq('No')
  end

  it "returns course length" do
    expect(course.length).to eq('1 year')
  end
end
