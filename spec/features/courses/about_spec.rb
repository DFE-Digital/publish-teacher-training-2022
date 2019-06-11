require 'rails_helper'

feature 'About course', type: :feature do
  let(:course_1) { jsonapi :course, name: 'English', provider: provider, include_nulls: [:accrediting_provider] }
  let(:course_2) { jsonapi :course, name: 'Biology', include_nulls: [:accrediting_provider] }
  let(:course_3) { jsonapi :course, name: 'Physics', include_nulls: [:accrediting_provider] }
  let(:course_4) { jsonapi :course, name: 'Science', include_nulls: [:accrediting_provider] }
  let(:courses)  { [course_2, course_3, course_4] }
  let(:provider) do
    jsonapi(:provider, courses: courses, accredited_body?: true, provider_code: 'AO')
  end
  let(:provider_response) { provider.render }
  let(:course)            { course_1.to_resource }
  let(:course_response)   { course_1.render }

  before do
    stub_omniauth
    stub_api_v2_request(
      "/providers/AO/courses/#{course.course_code}?include=sites,provider.sites,accrediting_provider",
      course_response
    )
    stub_api_v2_request(
      "/providers/AO?include=courses.accrediting_provider",
      provider_response
    )
    stub_api_v2_request(
      "/providers/AO/courses/#{course.course_code}",
      course_response,
      :patch
    )
  end

  let(:about_course_page) { PageObjects::Page::Organisations::CourseAbout.new }

  scenario 'viewing the about courses page' do
    visit description_provider_course_path(provider.provider_code, course.course_code)

    click_on 'About this course'

    expect(current_path).to eq about_provider_course_path('AO', course.course_code)

    expect(about_course_page.caption).to have_content(
      "#{course.name} (#{course.course_code})"
    )
    expect(about_course_page.title).to have_content(
      "About this course"
    )
    expect(about_course_page.about_textarea).to have_content(
      course.about_course
    )
    expect(about_course_page.interview_process_textarea).to have_content(
      course.interview_process
    )
    expect(about_course_page.how_school_placements_work_textarea).to have_content(
      course.how_school_placements_work
    )

    fill_in 'About this course', with: 'Something interesting about this course'
    fill_in 'How school placements work', with: 'Something about how school placements work'

    click_on 'Save'

    expect(about_course_page.flash).to have_content(
      'Your changes have been saved'
    )
    expect(current_path).to eq description_provider_course_path('AO', course.course_code)
  end

  context 'when a provider has no self accredited courses (for example a School Direct provider)' do
    let(:course_1) { jsonapi :course, provider: provider, name: 'Computing', accrediting_provider: accredited_body }
    let(:course_2) { jsonapi :course, name: 'Drama', accrediting_provider: accredited_body }
    let(:courses)  { [course_2] }
    let(:accredited_body) { jsonapi(:provider, accredited_body?: true, provider_code: 'A1') }
    let(:provider) { jsonapi(:provider, courses: courses, accredited_body?: false, provider_code: 'AO') }

    scenario 'viewing the about courses page' do
      visit about_provider_course_path('AO', course.course_code)

      expect(about_course_page.caption).to have_content(
        "#{course.name} (#{course.course_code})"
      )
    end
  end
end
