require 'rails_helper'

describe CourseDecorator do
  let(:current_recruitment_cycle) { build :recruitment_cycle }
  let(:next_recruitment_cycle) { build :recruitment_cycle, :next_cycle }
  let(:provider) { build(:provider, accredited_body?: false) }
  let(:course) {
    build :course,
          course_code: 'A1',
          name: 'Mathematics',
          qualification: 'pgce_with_qts',
          study_mode: 'full_time',
          start_date: Time.zone.local(2019),
          site_statuses: [site_status],
          provider: provider,
          accrediting_provider: provider,
          course_length: 'OneYear',
          open_for_applications?: true,
          last_published_at: '2019-03-05T14:42:34Z',
          recruitment_cycle: current_recruitment_cycle
  }
  let(:site) { build(:site) }
  let(:site_status) do
    build(:site_status, :full_time_and_part_time, site: site)
  end

  let(:course_response) {
    course.to_jsonapi(
      include: %i[sites provider accrediting_provider recruitment_cycle]
    )
  }

  let(:decorated_course) { course.decorate }

  it "returns the course name and code in brackets" do
    expect(decorated_course.name_and_code).to eq('Mathematics (A1)')
  end

  it "returns a list of subjects in alphabetical order" do
    expect(decorated_course.sorted_subjects).to eq('English<br>English with Primary')
  end

  it "returns if applications are open or closed" do
    expect(decorated_course.open_or_closed_for_applications).to eq('Open')
  end

  it "returns if course is an apprenticeship" do
    expect(decorated_course.apprenticeship?).to eq('No')
  end

  it "returns if course is SEND?" do
    expect(decorated_course.is_send?).to eq('No')
  end

  it "returns course length" do
    expect(decorated_course.length).to eq('1 year')
  end

  context 'recruitment cycles' do
    before do
      allow(Settings).to receive(:current_cycle).and_return(2019)
    end

    context 'for a course in the current cycle' do
      let(:course) {
        build(:course, recruitment_cycle: current_recruitment_cycle)
      }

      it 'knows which cycle it’s in' do
        expect(decorated_course.next_cycle?).to eq(false)
        expect(decorated_course.current_cycle?).to eq(true)
      end
    end

    context 'for a course in the next cycle' do
      let(:course) {
        build(:course, recruitment_cycle: next_recruitment_cycle)
      }

      it 'knows which cycle it’s in' do
        expect(decorated_course.next_cycle?).to eq(true)
        expect(decorated_course.current_cycle?).to eq(false)
      end
    end
  end
end
