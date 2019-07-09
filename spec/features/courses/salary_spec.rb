require 'rails_helper'

feature 'Course salary', type: :feature do
  let(:current_recruitment_cycle) { jsonapi(:recruitment_cycle, year: '2019') }
  let(:provider) do
    jsonapi(:provider, provider_code: 'A0')
  end

  let(:course) do
    jsonapi(
      :course,
      name: 'English',
      provider: provider,
      course_length: 'OneYear',
      salary_details: 'Salary details',
      funding: 'salary'
    )
  end

  before do
    stub_omniauth
    stub_api_v2_request("/recruitment_cycles/#{current_recruitment_cycle.year}/recruitment_cycles/#{current_recruitment_cycle.year}", current_recruitment_cycle.render)
    stub_course_request(provider, course)
    stub_api_v2_request("/recruitment_cycles/#{current_recruitment_cycle.year}/providers/A0?include=courses.accrediting_provider", provider.render)
  end

  let(:course_salary_page) { PageObjects::Page::Organisations::CourseSalary.new }

  scenario 'viewing the courses salary page' do
    stub_api_v2_request(
      "/recruitment_cycles/#{current_recruitment_cycle.year}/providers/#{provider.provider_code}/courses/#{course.course_code}",
      course.render, :patch, 200
    )
    visit provider_recruitment_cycle_course_path(provider.provider_code, course.recruitment_cycle_year, course.course_code)

    click_on 'Course length and salary'

    expect(current_path).to eq salary_provider_recruitment_cycle_course_path('A0', course.recruitment_cycle_year, course.course_code)

    expect(course_salary_page.caption).to have_content(
      "#{course.name} (#{course.course_code})"
    )
    expect(course_salary_page.title).to have_content(
      "Course length and salary"
    )
    expect(course_salary_page).to have_enrichment_form
    expect(course_salary_page.course_length_one_year).to be_checked
    expect(course_salary_page.course_length_two_years).to_not be_checked
    expect(course_salary_page.course_length_other_length.value).to eq('')
    expect(course_salary_page.course_salary_details.value).to eq(
      course.salary_details
    )

    choose '2 years'
    fill_in 'Salary', with: 'Test salary details'
    click_on 'Save'

    expect(course_salary_page.flash).to have_content(
      'Your changes have been saved'
    )

    expect(current_path).to eq provider_recruitment_cycle_course_path('A0', course.recruitment_cycle_year, course.course_code)
  end

  scenario 'submitting with validation errors' do
    stub_api_v2_request(
      "/providers/#{provider.provider_code}/courses/#{course.course_code}",
      build(:error, :for_course_publish), :patch, 422
    )

    visit salary_provider_recruitment_cycle_course_path(provider.provider_code, course.recruitment_cycle_year, course.course_code)

    fill_in 'Salary', with: 'foo ' * 401
    click_on 'Save'

    expect(course_salary_page.error_flash).to have_content(
      'You’ll need to correct some information.'
    )
    expect(current_path).to eq salary_provider_recruitment_cycle_course_path(provider.provider_code, course.recruitment_cycle_year, course.course_code)
  end

  context 'when copying course salary from another course' do
    let(:course_2) {
      jsonapi(
        :course,
        name: 'Biology',
        provider: provider,
        course_length: 'TwoYears',
        salary_details: 'Course 2 salary details',
        funding: 'salary'
      )
    }

    let(:course_3) {
      jsonapi(
        :course,
        name: 'Biology',
        provider: provider,
        course_length: 'TwoYears',
        funding: 'salary'
      )
    }

    let(:provider_for_copy_from_list) do
      jsonapi(:provider, courses: [course, course_2, course_3], provider_code: 'A0')
    end

    before do
      stub_course_request(provider, course_2)
      stub_course_request(provider, course_3)
      stub_api_v2_request("/providers/A0?include=courses.accrediting_provider", provider_for_copy_from_list.render)
    end

    scenario 'all fields get copied if all were present' do
      course_salary_page.load_with_course(course)
      course_salary_page.copy_content.copy(course_2)

      [
        'Your changes are not yet saved',
        'Course length',
        'Salary details'
      ].each do |name|
        expect(course_salary_page.warning_message).to have_content(name)
      end

      expect(course_salary_page.course_length_one_year).to_not be_checked
      expect(course_salary_page.course_length_two_years).to be_checked
      expect(course_salary_page.course_salary_details.value).to eq(course_2.salary_details)
    end

    scenario 'only fields with values are copied if the source was incomplete' do
      course_salary_page.load_with_course(course_2)
      course_salary_page.copy_content.copy(course_3)

      [
        'Your changes are not yet saved',
        'Course length'
      ].each do |name|
        expect(course_salary_page.warning_message).to have_content(name)
      end

      [
        'Salary details'
      ].each do |name|
        expect(course_salary_page.warning_message).not_to have_content(name)
      end

      expect(course_salary_page.course_length_one_year).to_not be_checked
      expect(course_salary_page.course_length_two_years).to be_checked
      expect(course_salary_page.course_salary_details.value).to eq(course_2.salary_details)
    end
  end

  def stub_course_request(provider, course)
    stub_api_v2_request(
      "/providers/#{provider.provider_code}/courses/#{course.course_code}?include=sites,provider.sites,accrediting_provider",
      course.render
    )
  end
end
