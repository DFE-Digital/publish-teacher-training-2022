require 'rails_helper'

feature 'About course', type: :feature do
  let(:provider) do
    jsonapi(:provider, provider_code: 'AO')
  end

  let(:course) do
    jsonapi(
      :course,
      name: 'English',
      provider: provider,
      about_course: 'About course',
      interview_process: 'Interview process',
      how_school_placements_work: 'How school placements work'
    )
  end

  before do
    stub_omniauth
    stub_course_request(provider, course)
    stub_api_v2_request("/providers/AO?include=courses.accrediting_provider", provider.render)
    stub_api_v2_request("/providers/AO/courses/#{course.course_code}", course.render, :patch)
  end

  let(:about_course_page) { PageObjects::Page::Organisations::CourseAbout.new }

  scenario 'viewing the about courses page' do
    visit description_provider_course_path(provider.provider_code, course.course_code)
    click_on 'About this course'

    expect(current_path).to eq about_provider_course_path(provider.provider_code, course.course_code)

    expect(about_course_page.caption).to have_content(
      "#{course.name} (#{course.course_code})"
    )
    expect(about_course_page.title).to have_content(
      "About this course"
    )
    expect(about_course_page.about_textarea.value).to eq(
      course.about_course
    )
    expect(about_course_page.interview_process_textarea.value).to eq(
      course.interview_process
    )
    expect(about_course_page.how_school_placements_work_textarea.value).to eq(
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

  context 'when copying course requirements from another course' do
    let(:course_2) {
      jsonapi(
        :course,
        name: 'Biology',
        provider: provider,
        about_course: 'Course 2 - About course',
        interview_process: 'Course 2 - Interview process',
        how_school_placements_work: 'Course 2 - How school placements work'
      )
    }

    let(:course_3) {
      jsonapi(
        :course,
        name: 'Biology',
        provider: provider,
        about_course: 'Course 3 - About course'
      )
    }

    let(:provider_for_copy_from_list) do
      jsonapi(:provider, courses: [course, course_2, course_3], provider_code: 'AO')
    end

    before do
      stub_course_request(provider, course_2)
      stub_course_request(provider, course_3)
      stub_api_v2_request("/providers/AO?include=courses.accrediting_provider", provider_for_copy_from_list.render)
    end

    scenario 'all fields get copied if all were present' do
      copy_fees(from: course_2, to: course)

      [
        'Your changes are not yet saved',
        'About the course',
        'Interview process',
        'How school placements work'
      ].each do |name|
        expect(about_course_page.warning_message).to have_content(name)
      end

      expect(about_course_page.about_textarea.value).to eq(course_2.about_course)
      expect(about_course_page.interview_process_textarea.value).to eq(course_2.interview_process)
      expect(about_course_page.how_school_placements_work_textarea.value).to eq(course_2.how_school_placements_work)
    end

    scenario 'only fields with values are copied if the source was incomplete' do
      copy_fees(from: course_3, to: course_2)

      [
        'Your changes are not yet saved',
        'About the course'
      ].each do |name|
        expect(about_course_page.warning_message).to have_content(name)
      end

      [
        'Interview process',
        'How school placements work'
      ].each do |name|
        expect(about_course_page.warning_message).not_to have_content(name)
      end

      expect(about_course_page.about_textarea.value).to eq(course_3.about_course)
      expect(about_course_page.interview_process_textarea.value).to eq(course_2.interview_process)
      expect(about_course_page.how_school_placements_work_textarea.value).to eq(course_2.how_school_placements_work)
    end
  end

  def copy_fees(from:, to:)
    visit about_provider_course_path(provider.provider_code, to.course_code)
    select("#{from.name} (#{from.course_code})", from: 'Copy from')
    click_on('Copy content')
  end

  def stub_course_request(provider, course)
    stub_api_v2_request(
      "/providers/#{provider.provider_code}/courses/#{course.course_code}?include=sites,provider.sites,accrediting_provider",
      course.render
    )
  end
end
