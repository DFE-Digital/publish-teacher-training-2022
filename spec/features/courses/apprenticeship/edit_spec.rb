require 'rails_helper'

feature 'Edit course apprenticeship status', type: :feature do
  let(:current_recruitment_cycle) { build(:recruitment_cycle) }
  let(:apprenticeship_page) { PageObjects::Page::Organisations::CourseApprenticeship.new }
  let(:course_details_page) { PageObjects::Page::Organisations::CourseDetails.new }
  let(:provider) { build(:provider, accredited_body?: true) }

  before do
    stub_omniauth
    stub_api_v2_request(
      "/recruitment_cycles/#{current_recruitment_cycle.year}",
      current_recruitment_cycle.to_jsonapi
    )
    stub_api_v2_request(
      "/recruitment_cycles/#{current_recruitment_cycle.year}" \
      "/providers/#{provider.provider_code}?include=courses.accrediting_provider",
      provider.to_jsonapi(include: %i[courses accrediting_provider])
    )

    stub_course_request
    stub_course_details_tab
    apprenticeship_page.load_with_course(course)
  end

  context 'A course that can be an apprenticeship' do
    let(:program_type) { 'pg_teaching_apprenticeship' }
    let(:program_types) { %w[pg_teaching_apprenticeship higher_education_programme] }
    let(:course) do
      build(
        :course,
        program_type: program_type,
        edit_options: {
          program_type: program_types
        },
        provider: provider
      )
    end

    scenario 'can cancel changes' do
      click_on 'Cancel changes'
      expect(course_details_page).to be_displayed
    end

    xscenario 'can navigate to the edit screen and back again' do
      course_details_page.load_with_course(course)
      click_on 'Change apprenticeship'
      expect(apprenticeship_page).to be_displayed
      click_on 'Back'
      expect(course_details_page).to be_displayed
    end

    context 'with pg_teaching_apprenticeship and higher_education_programme' do
      scenario 'presents the correct choices for each study mode' do
        expect(apprenticeship_page).to have_program_type_fields
        expect(apprenticeship_page.program_type_fields)
          .to have_selector('[for="course_program_type_pg_teaching_apprenticeship"]', text: 'Yes')
        expect(apprenticeship_page.program_type_fields)
          .to have_selector('[for="course_program_type_higher_education_programme"]', text: 'No')
      end

      context 'and it is an apprenticeship' do
        scenario 'it has the correct value selected' do
          expect(apprenticeship_page.program_type_fields)
            .to have_field('course_program_type_pg_teaching_apprenticeship', checked: true)
          expect(apprenticeship_page.program_type_fields)
            .to have_field('course_program_type_higher_education_programme', checked: false)
        end
      end

      context 'and it is not an apprenticeship' do
        let(:program_type) { 'higher_education_programme' }

        scenario 'it has the correct value selected' do
          expect(apprenticeship_page.program_type_fields)
            .to have_field('course_program_type_pg_teaching_apprenticeship', checked: false)
          expect(apprenticeship_page.program_type_fields)
            .to have_field('course_program_type_higher_education_programme', checked: true)
        end
      end

      scenario 'it can be updated to a higher education program' do
        update_course_stub = stub_api_v2_request(
          "/recruitment_cycles/#{course.recruitment_cycle.year}" \
          "/providers/#{provider.provider_code}" \
          "/courses/#{course.course_code}",
          course.to_jsonapi,
          :patch, 200
        )

        choose('course_program_type_higher_education_programme')
        click_on 'Save'

        expect(course_details_page).to be_displayed
        expect(course_details_page.flash).to have_content('Your changes have been saved')
        expect(update_course_stub).to have_been_requested
      end
    end

    context 'with pg_teaching_apprenticeship and scitt_programme' do
      let(:program_types) { %w[pg_teaching_apprenticeship scitt_programme] }

      scenario 'presents the correct choices for each study mode' do
        expect(apprenticeship_page).to have_program_type_fields
        expect(apprenticeship_page.program_type_fields)
          .to have_selector('[for="course_program_type_pg_teaching_apprenticeship"]', text: 'Yes')
        expect(apprenticeship_page.program_type_fields)
          .to have_selector('[for="course_program_type_scitt_programme"]', text: 'No')
      end

      context 'and it is an apprenticeship' do
        scenario 'it has the correct value selected' do
          expect(apprenticeship_page.program_type_fields)
            .to have_field('course_program_type_pg_teaching_apprenticeship', checked: true)
          expect(apprenticeship_page.program_type_fields)
            .to have_field('course_program_type_scitt_programme', checked: false)
        end
      end

      context 'and it is not an apprenticeship' do
        let(:program_type) { 'scitt_programme' }

        scenario 'it has the correct value selected' do
          expect(apprenticeship_page.program_type_fields)
            .to have_field('course_program_type_pg_teaching_apprenticeship', checked: false)
          expect(apprenticeship_page.program_type_fields)
            .to have_field('course_program_type_scitt_programme', checked: true)
        end
      end

      scenario 'it can be updated to a scitt programme' do
        update_course_stub = stub_api_v2_request(
          "/recruitment_cycles/#{course.recruitment_cycle.year}" \
          "/providers/#{provider.provider_code}" \
          "/courses/#{course.course_code}",
          course.to_jsonapi,
          :patch, 200
        )

        choose('course_program_type_scitt_programme')
        click_on 'Save'

        expect(course_details_page).to be_displayed
        expect(course_details_page.flash).to have_content('Your changes have been saved')
        expect(update_course_stub).to have_been_requested
      end
    end
  end

  def stub_course_request
    stub_api_v2_request(
      "/recruitment_cycles/#{current_recruitment_cycle.year}" \
      "/providers/#{provider.provider_code}/courses" \
      "/#{course.course_code}",
      course.to_jsonapi
    )
  end

  def stub_course_details_tab
    stub_api_v2_request(
      "/recruitment_cycles/#{course.recruitment_cycle.year}" \
      "/providers/#{provider.provider_code}" \
      "/courses/#{course.course_code}" \
      "?include=sites,provider.sites,accrediting_provider",
      course.to_jsonapi(include: [:sites, :accrediting_provider, :recruitment_cycle, provider: :sites])
    )
  end
end
