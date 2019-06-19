require 'rails_helper'

describe 'Courses', type: :request do
  describe 'GET about' do
    let(:course_json_api)   { jsonapi :course, name: 'English', course_code: 'EN01', provider: provider, include_nulls: [:accrediting_provider] }
    let(:provider)          { jsonapi(:provider, accredited_body?: true, provider_code: 'AO') }
    let(:course)            { course_json_api.to_resource }
    let(:course_response)   { course_json_api.render }

    let(:course_1_json_api) { jsonapi :course, name: 'English', course_code: 'EN01', include_nulls: [:accrediting_provider] }
    let(:course_2_json_api) do
      jsonapi :course,
              name: 'Biology',
              include_nulls: [:accrediting_provider],
              about_course: 'Foo',
              interview_process: 'Foobar',
              how_school_placements_work: 'Foobarbar'
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

    it 'renders the course about' do
      get(about_provider_course_path(provider_code: provider.provider_code,
                                     code: course.course_code))

      expect(response.body).to include(
        "#{course.name} (#{course.course_code})"
      )
      expect(response.body).to include(
        'About this course'
      )
      expect(response.body).to_not include(
        'Your changes are not yet saved'
      )
    end

    context 'with copy_from parameter' do
      it 'renders the course about with data from chosen' do
        get(about_provider_course_path(provider_code: provider.provider_code,
                                       code: course.course_code,
                                       params: { copy_from: course_2.course_code }))

        expect(response.body).to include(
          'Your changes are not yet saved'
        )
        expect(response.body).to include(
          course_2.about_course
        )
        expect(response.body).to include(
          course_2.interview_process
        )
        expect(response.body).to include(
          course_2.how_school_placements_work
        )
      end
    end
  end

  describe 'UPDATE about' do
    let(:course_json_api)   { jsonapi :course, provider: provider }
    let(:provider)          { jsonapi(:provider, provider_code: 'AO') }
    let(:course)            { course_json_api.to_resource }
    let(:course_response)   { course_json_api.render }

    let(:course_params) do
      {
        page: "about",
        about_course: "Something about this course",
        how_school_placements_work: "Something about how school placements work",
        interview_process: "Something about the interview process",
      }
    end

    let(:request_params) do
      {
        "_jsonapi" => {
          data: {
            course_code: course.course_code,
            type: "courses",
            attributes: course_params
          }
        },
        "course" => course_params
      }
    end

    before do
      stub_omniauth
      get(auth_dfe_callback_path)
      stub_api_v2_request(
        "/providers/#{provider.provider_code}/courses/#{course.course_code}?include=sites,provider.sites,accrediting_provider",
        course_response
      )
      stub_api_v2_request(
        "/providers/#{provider.provider_code}?include=courses.accrediting_provider",
        provider.render
      )
    end

    context "without errors" do
      before do
        stub_api_v2_request(
          "/providers/#{provider.provider_code}/courses/#{course.course_code}",
          {}, :patch, 200
        ).with(body: {
          data: {
            course_code: course.course_code,
            type: "courses",
            attributes: course_params
          }
        }.to_json)

        patch about_provider_course_path(provider.provider_code, course.course_code), params: request_params
      end

      it 'redirects to the course description page' do
        expect(flash[:success]).to include('Your changes have been saved')
        expect(response).to redirect_to(description_provider_course_path(provider.provider_code, course.course_code))
      end
    end

    context "with errors" do
      before do
        stub_api_v2_request(
          "/providers/#{provider.provider_code}/courses/#{course.course_code}",
          build(:error, :for_course_publish), :patch, 422
        )

        patch about_provider_course_path(provider.provider_code, course.course_code), params: request_params
      end

      it 'redirects to the course about page' do
        expect(response).to render_template :about
      end
    end
  end
end
