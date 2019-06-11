require 'rails_helper'

feature 'Course requirements', type: :feature do
  let(:provider) do
    jsonapi(:provider, provider_code: 'AO')
  end

  let(:course) do
    jsonapi(
      :course,
      name: 'English',
      provider: provider,
      required_qualifications: 'Required qualifications',
      personal_qualities: 'Personal qualities',
      other_requirements: 'Other requirements'
    )
  end

  before do
    stub_omniauth
    stub_course_request(provider, course)
    stub_api_v2_request("/providers/AO?include=courses.accrediting_provider", provider.render)
    stub_api_v2_request("/providers/AO/courses/#{course.course_code}", course.render, :patch)
  end

  let(:course_requirements_page) { PageObjects::Page::Organisations::CourseRequirements.new }

  scenario 'viewing the courses requirements page' do
    visit description_provider_course_path(provider.provider_code, course.course_code)
    click_on 'Requirements and eligibility'

    expect(current_path).to eq requirements_provider_course_path('AO', course.course_code)

    expect(course_requirements_page.caption).to have_content(
      "#{course.name} (#{course.course_code})"
    )
    expect(course_requirements_page.title).to have_content(
      "Requirements and eligibility"
    )
    expect(course_requirements_page.required_qualifications.value).to eq(
      course.required_qualifications
    )
    expect(course_requirements_page.personal_qualities.value).to eq(
      course.personal_qualities
    )
    expect(course_requirements_page.other_requirements.value).to eq(
      course.other_requirements
    )

    fill_in 'Qualifications needed', with: 'Something about the qualifications required for this course'
    fill_in 'Personal qualities (optional)', with: 'Something about the personal qualities required for this course'
    fill_in 'Other requirements (optional)', with: 'Something about the other requirements required for this course'

    click_on 'Save'

    expect(course_requirements_page.flash).to have_content(
      'Your changes have been saved'
    )

    expect(current_path).to eq description_provider_course_path('AO', course.course_code)
  end

  context 'when copying course requirements from another course' do
    let(:course_2) {
      jsonapi(
        :course,
        name: 'Biology',
        provider: provider,
        required_qualifications: 'Course 2 required qualifications',
        personal_qualities: 'Course 2 personal qualities',
        other_requirements: 'Course 2 other requirements'
      )
    }

    let(:course_3) {
      jsonapi(
        :course,
        name: 'Biology',
        provider: provider,
        required_qualifications: 'Required qualifications'
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
        'Qualifications needed',
        'Personal qualities',
        'Other requirements'
      ].each do |name|
        expect(course_requirements_page.warning_message).to have_content(name)
      end

      expect(course_requirements_page.required_qualifications.value).to eq(course_2.required_qualifications)
      expect(course_requirements_page.personal_qualities.value).to eq(course_2.personal_qualities)
      expect(course_requirements_page.other_requirements.value).to eq(course_2.other_requirements)
    end

    scenario 'only fields with values are copied if the source was incomplete' do
      copy_fees(from: course_3, to: course_2)

      [
        'Your changes are not yet saved',
        'Qualifications needed'
      ].each do |name|
        expect(course_requirements_page.warning_message).to have_content(name)
      end

      [
        'Personal qualities',
        'Other requirements'
      ].each do |name|
        expect(course_requirements_page.warning_message).not_to have_content(name)
      end

      expect(course_requirements_page.required_qualifications.value).to eq(course_3.required_qualifications)
      expect(course_requirements_page.personal_qualities.value).to eq(course_2.personal_qualities)
      expect(course_requirements_page.other_requirements.value).to eq(course_2.other_requirements)
    end
  end

  def copy_fees(from:, to:)
    visit requirements_provider_course_path(provider.provider_code, to.course_code)
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
