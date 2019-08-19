require "rails_helper"

describe Course do
  describe '#fetch_new' do
    let(:provider)          { build :provider }
    let(:course)            { build :course, :new, provider: provider }
    let(:recruitment_cycle) { course.recruitment_cycle }
    let(:new_resource_stub) { stub_api_v2_new_resource(course) }

    before do
      allow(Thread.current).to receive(:fetch).and_return('token')

      stub_omniauth
      new_resource_stub
    end

    let(:fetched_new_course) do
      Course.fetch_new(
        recruitment_cycle_year: recruitment_cycle.year,
        provider_code: provider.provider_code
      )
    end

    it 'makes a request to the api' do
      fetched_new_course

      expect(new_resource_stub).to have_been_requested
    end

    it 'returns the result' do
      expect(fetched_new_course.id).to eq nil
      expect(fetched_new_course.type).to eq 'courses'
    end
  end
end
