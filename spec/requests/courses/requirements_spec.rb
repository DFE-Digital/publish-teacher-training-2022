require 'rails_helper'

describe 'Courses', type: :request do
  describe 'GET requirements' do
    let(:course_json_api)   { jsonapi :course, name: 'English', course_code: 'EN01', provider: provider, include_nulls: [:accrediting_provider] }
    let(:provider)          { jsonapi(:provider, accredited_body?: true, provider_code: 'A0') }
    let(:course)            { course_json_api.to_resource }
    let(:course_response)   { course_json_api.render }

    let(:course_1_json_api) { jsonapi :course, name: 'English', course_code: 'EN01', include_nulls: [:accrediting_provider] }
    let(:course_2_json_api) do
      jsonapi :course,
              name: 'Biology',
              include_nulls: [:accrediting_provider],
              required_qualifications: 'Foo',
              personal_qualities: 'Foobar',
              other_requirements: 'Foobarbar'
    end
    let(:course_2)            { course_2_json_api.to_resource }
    let(:courses)             { [course_1_json_api, course_2_json_api] }
    let(:provider2)           { jsonapi(:provider, courses: courses, accredited_body?: true, provider_code: 'A0') }
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

    context 'Default recruitment cycle' do
      it 'should redirect to new courses#requirements route' do
        get("/organisations/#{provider.provider_code}/courses/#{course.course_code}/requirements")
        expect(response).to redirect_to(requirements_provider_recruitment_cycle_course_path(provider.provider_code, '2019', course.course_code))
      end
    end

    it 'renders the course requirements' do
      get(requirements_provider_recruitment_cycle_course_path(provider.provider_code,
                                                              course.recruitment_cycle_year,
                                                              course.course_code))

      expect(response.body).to include(
        "#{course.name} (#{course.course_code})"
      )
      expect(response.body).to include(
        'Requirements and eligibility'
      )
      expect(response.body).to_not include(
        'Your changes are not yet saved'
      )
    end

    context 'with copy_from parameter' do
      it 'renders the course requirements with data from chosen' do
        get(requirements_provider_recruitment_cycle_course_path(provider.provider_code,
                                                                course.recruitment_cycle_year,
                                                                course.course_code,
                                                                params: { copy_from: course_2.course_code }))

        expect(response.body).to include(
          'Your changes are not yet saved'
        )
        expect(response.body).to include(
          course_2.required_qualifications
        )
        expect(response.body).to include(
          course_2.personal_qualities
        )
        expect(response.body).to include(
          course_2.other_requirements
        )
      end
    end
  end
end
