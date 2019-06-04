require 'rails_helper'

describe 'Courses', type: :request do
  describe 'GET fees' do
    let(:course_json_api)   { jsonapi :course, name: 'English', course_code: 'EN01', provider: provider, include_nulls: [:accrediting_provider] }
    let(:provider)          { jsonapi(:provider, accredited_body?: true, provider_code: 'AO') }
    let(:course)            { course_json_api.to_resource }
    let(:course_response)   { course_json_api.render }

    let(:course_1_json_api) { jsonapi :course, name: 'English', course_code: 'EN01', include_nulls: [:accrediting_provider] }
    let(:course_2_json_api) do
      jsonapi :course,
              name: 'Biology',
              include_nulls: [:accrediting_provider],
              course_length: 'TwoYears',
              fee_uk_eu: '9500',
              fee_international: '1200',
              fee_details: 'Some information about the fees',
              financial_support: 'Some information about the finance support'
    end
    let(:course_2)            { course_2_json_api.to_resource }
    let(:courses)             { [course_1_json_api, course_2_json_api] }
    let(:provider2)           { jsonapi(:provider, courses: courses, accredited_body?: true, provider_code: 'AO') }
    let(:provider_2_response) { provider2.render }

    before do
      stub_omniauth
      get(auth_dfe_callback_path)
      stub_api_v2_request(
        "/providers/#{provider.provider_code}/courses/#{course.course_code}?include=sites,provider.sites,accrediting_provider",
        course_response
      )
      stub_api_v2_request(
        "/providers/#{provider.provider_code}/courses/#{course_2.course_code}?include=sites,provider.sites,accrediting_provider",
        course_2_json_api.render
      )
      stub_api_v2_request(
        "/providers/#{provider.provider_code}?include=courses.accrediting_provider",
        provider_2_response
      )
    end

    it 'renders the course length and fees' do
      get(fees_provider_course_path(provider_code: provider.provider_code,
                                    code: course.course_code))

      expect(response.body).to include(
        "#{course.name} (#{course.course_code})"
      )
      expect(response.body).to include(
        'Course length and fees'
      )
      expect(response.body).to_not include(
        'Your changes are not yet saved'
      )
    end

    context 'with copy_form parameter' do
      it 'renders the course length and fees with data from chosen' do
        get(fees_provider_course_path(provider_code: provider.provider_code,
                                      code: course.course_code,
                                      params: { copy_from: course_2.course_code }))

        expect(response.body).to include(
          'Your changes are not yet saved'
        )
        expect(response.body).to include(
          course_2.course_length
        )
        expect(response.body).to include(
          course_2.fee_uk_eu
        )
        expect(response.body).to include(
          course_2.fee_international
        )
        expect(response.body).to include(
          course_2.fee_details
        )
        expect(response.body).to include(
          course_2.financial_support
        )
      end
    end
  end
end
