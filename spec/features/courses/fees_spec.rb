require 'rails_helper'

feature 'Course fees', type: :feature do
  let(:provider) { jsonapi(:provider, provider_code: 'AO') }
  let(:course_1) do
    jsonapi(
      :course,
      :with_fees,
      provider: provider
    )
  end

  before do
    stub_omniauth
    stub_course_request(provider, course_1)
    stub_api_v2_request("/providers/AO?include=courses.accrediting_provider", provider.render)
  end

  let(:course_fees_page) { PageObjects::Page::Organisations::CourseFees.new }

  scenario 'viewing the courses fees page' do
    stub_api_v2_request(
      "/providers/#{provider.provider_code}/courses/#{course_1.course_code}",
      course_1.render, :patch, 200
    )
    visit provider_course_path(provider.provider_code, course_1.course_code)

    click_on 'Course length and fees'

    expect(current_path).to eq fees_provider_course_path('AO', course_1.course_code)

    expect(course_fees_page.caption).to have_content(
      "#{course_1.name} (#{course_1.course_code})"
    )
    expect(course_fees_page.title).to have_content(
      "Course length and fees"
    )
    expect(course_fees_page.course_length_one_year).not_to be_checked
    expect(course_fees_page.course_length_two_years).to be_checked
    expect(course_fees_page.course_length_other_length.value).to eq('')

    expect(course_fees_page.course_fees_uk_eu.value).to have_content(
      course_1.fee_uk_eu
    )
    expect(course_fees_page.course_fees_international.value).to have_content(
      course_1.fee_international
    )
    expect(course_fees_page.fee_details).to have_content(
      course_1.fee_details
    )
    expect(course_fees_page.financial_support).to have_content(
      course_1.financial_support
    )

    choose '1 year'
    fill_in 'Fee for UK and EU students', with: 8000
    fill_in 'Fee for international students (optional)', with: 16000
    fill_in 'Fee details (optional)', with: 'Test fee details'
    fill_in(
      'Financial support you offer (optional)',
      with: 'Test financial support'
    )

    click_on 'Save'

    expect(course_fees_page.flash).to have_content(
      'Your changes have been saved'
    )
    expect(current_path).to eq provider_course_path('AO', course_1.course_code)
  end

  scenario 'submitting with validation errors' do
    stub_api_v2_request(
      "/providers/#{provider.provider_code}/courses/#{course_1.course_code}",
      build(:error, :for_course_publish), :patch, 422
    )

    visit fees_provider_course_path(provider.provider_code, course_1.course_code)

    fill_in 'Fee for UK and EU students', with: 100_000_000
    click_on 'Save'

    expect(course_fees_page.error_flash).to have_content(
      'You’ll need to correct some information.'
    )
    expect(current_path).to eq fees_provider_course_path(provider.provider_code, course_1.course_code)
  end

  context 'with course_length_other selected' do
    let(:course_1) do
      jsonapi(
        :course,
        :with_fees,
        course_length: '6 months',
        provider: provider
      )
    end

    scenario 'passes the value into course_length' do
      visit provider_course_path(provider.provider_code, course_1.course_code)

      click_on 'Course length and fees'

      expect(current_path).to eq fees_provider_course_path('AO', course_1.course_code)

      expect(course_fees_page.course_length_other).to be_checked
      expect(course_fees_page.course_length_other_length.value).to eq('6 months')
    end
  end

  context 'when copying course fees from another course' do
    let(:course_2) {
      jsonapi(
        :course,
        name: 'Biology',
        provider: provider,
        course_length: 'Something custom',
        fee_uk_eu: 9500,
        fee_international: 1200,
        fee_details: 'Some information about the fees',
        financial_support: 'Some information about the finance support'
      )
    }

    let(:course_3) {
      jsonapi(
        :course,
        name: 'Biology',
        provider: provider,
        fee_details: 'Course 3 has just fee details',
        financial_support: 'and financial support (Course 3)'
      )
    }

    let(:provider_for_copy_from_list) do
      jsonapi(:provider, courses: [course_1, course_2, course_3], provider_code: 'AO')
    end

    before do
      stub_course_request(provider, course_2)
      stub_course_request(provider, course_3)
      stub_api_v2_request("/providers/AO?include=courses.accrediting_provider", provider_for_copy_from_list.render)
    end

    scenario 'all fields get copied if all were present' do
      course_fees_page.load_with_course(course_1)
      course_fees_page.copy_content.copy(course_2)

      [
        'Your changes are not yet saved',
        'Course length',
        'Fee details',
        'Financial support'
      ].each do |name|
        expect(course_fees_page.warning_message).to have_content(name)
      end

      expect(course_fees_page.course_length_one_year).to_not be_checked
      expect(course_fees_page.course_length_two_years).to_not be_checked
      expect(course_fees_page.course_length_other).to be_checked
      expect(course_fees_page.course_length_other_length.value).to eq('Something custom')
      expect(course_fees_page.course_fees_uk_eu.value).to eq(course_2.fee_uk_eu.to_s)
      expect(course_fees_page.course_fees_international.value).to eq(course_2.fee_international.to_s)
      expect(course_fees_page.fee_details.value).to eq(course_2.fee_details)
      expect(course_fees_page.financial_support.value).to eq(course_2.financial_support)
    end

    scenario 'only fields with values are copied if the source was incomplete' do
      course_fees_page.load_with_course(course_2)
      course_fees_page.copy_content.copy(course_3)

      [
        'Your changes are not yet saved',
        'Fee details',
        'Financial support'
      ].each do |name|
        expect(course_fees_page.warning_message).to have_content(name)
      end

      [
        'Course length',
      ].each do |name|
        expect(course_fees_page.warning_message).not_to have_content(name)
      end

      expect(course_fees_page.course_length_one_year).to_not be_checked
      expect(course_fees_page.course_length_two_years).to_not be_checked
      expect(course_fees_page.course_length_other).to be_checked
      expect(course_fees_page.course_length_other_length.value).to eq('Something custom')
      expect(course_fees_page.course_fees_uk_eu.value).to eq(course_2.fee_uk_eu.to_s)
      expect(course_fees_page.course_fees_international.value).to eq(course_2.fee_international.to_s)
      expect(course_fees_page.fee_details.value).to eq(course_3.fee_details)
      expect(course_fees_page.financial_support.value).to eq(course_3.financial_support)
    end
  end

  def stub_course_request(provider, course)
    stub_api_v2_request(
      "/providers/#{provider.provider_code}/courses/#{course.course_code}?include=sites,provider.sites,accrediting_provider",
      course.render
    )
  end
end
