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
            last_published_at: '2019-03-05T14:42:34Z',
            fee_uk_eu: '9250',
            fee_international: '9250').to_resource
  }
  let(:site) { jsonapi(:site) }
  let(:site_status) do
    jsonapi(:site_status, :full_time_and_part_time, site: site)
  end

  let(:course) { course_jsonapi.decorate }

  it "returns the course name and code in brackets" do
    expect(course.name_and_code).to eq('Mathematics (A1)')
  end

  it "returns a list of subjects in alphabetical order" do
    expect(course.sorted_subjects).to eq('English<br>English with Primary')
  end

  it "returns if applications are open or closed" do
    expect(course.open_or_closed_for_applications).to eq('Open')
  end

  it "returns if course is an apprenticeship" do
    expect(course.apprenticeship?).to eq('No')
  end

  it "returns if course is SEND?" do
    expect(course.is_send?).to eq('No')
  end

  it "returns course length" do
    expect(course.length).to eq('1 year')
  end

  it 'returns course uk fees' do
    expect(course.uk_fees).to eq('£9,250')
  end

  it 'returns course eu fees' do
    expect(course.eu_fees).to eq('£9,250')
  end

  it 'returns course international fees' do
    expect(course.international_fees).to eq('£9,250')
  end
end
