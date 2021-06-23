require "rails_helper"

feature "GCSE equivalency requirements", type: :feature do
 let(:course_page) { PageObjects::Page::Organisations::Course.new }
 let(:gcse_requirements_page) { PageObjects::Page::Organisations::Courses::GcseRequirementsPage.new }

 let(:provider) { build(:provider, recruitment_cycle: recruitment_cycle) }
 let(:course) { build(:course, provider: provider, recruitment_cycle: recruitment_cycle, accept_pending_gcse: false, accept_gcse_equivalency: false,
   accept_english_gcse_equivalency: false, accept_maths_gcse_equivalency: false, accept_science_gcse_equivalency: false, additional_gcse_equivalencies: nil) }
 let(:course2) { build(:course, provider: provider, recruitment_cycle: recruitment_cycle, accept_pending_gcse: true, accept_gcse_equivalency: true,
   accept_english_gcse_equivalency: true, accept_maths_gcse_equivalency: true, accept_science_gcse_equivalency: true, additional_gcse_equivalencies: "Cycling Proficiency") }
 let(:recruitment_cycle) { build(:recruitment_cycle, :next_cycle) }

 before do
   signed_in_user(provider: provider)
   stub_api_v2_resource(provider)
   stub_api_v2_resource(recruitment_cycle)
   stub_api_v2_resource_collection([course], include: "subjects,sites,provider.sites,accrediting_provider")
   stub_api_v2_resource(course, include: "subjects,sites,provider.sites,accrediting_provider")
   stub_api_v2_resource(course, include: "provider")
   stub_api_v2_resource(course2, include: "provider")
   stub_api_v2_resource(course2, include: "subjects,sites,provider.sites,accrediting_provider")
   stub_api_v2_resource(primary_course, include: "provider")
   stub_api_v2_resource(primary_course, include: "provider")
   stub_api_v2_resource(primary_course, include: "subjects,sites,provider.sites,accrediting_provider")
   stub_api_v2_request(
     "/recruitment_cycles/#{course.recruitment_cycle.year}" \
     "/providers/#{provider.provider_code}" \
     "/courses/#{course.course_code}",
     course.to_jsonapi,
     :patch,
     200,
   )
   stub_api_v2_request(
     "/recruitment_cycles/#{course.recruitment_cycle.year}" \
     "/providers/#{provider.provider_code}" \
     "/courses/#{course.course_code}/gcse", \
     course2.to_jsonapi,
     :get,
     200,
   )
   stub_api_v2_request(
     "/recruitment_cycles/#{primary_course.recruitment_cycle.year}" \
     "/providers/#{provider.provider_code}" \
     "/courses/#{primary_course.course_code}", \
     primary_course.to_jsonapi,
     :get,
     200,
   )
   stub_api_v2_request(
     "/recruitment_cycles/#{primary_course.recruitment_cycle.year}" \
     "/providers/#{provider.provider_code}" \
     "/courses/#{primary_course.course_code}", \
     primary_course.to_jsonapi,
     :patch,
     200,
   )
 end

 scenario "a provider completes the gcse equivalency requirements section and provides a classification" do
   course_page.load_with_course(course)
   visit_description_page(course)
   click_link "Enter GCSEs and equivalency test requirements"
   choose "Yes"
   gcse_equivalency_page.save.click
   expect(page).to have_current_path provider_recruitment_cycle_course_path(
     provider.provider_code,
     course.recruitment_cycle.year,
     course.course_code,
   )
 end

 scenario "a provider has completed the degree section and sees their answer pre-populated on the gcse requirements page" do
   course_page.load_with_course(course2)
   visit_gcse_requirements_page

   expect(gcse_requirements_page.no_radio).to be_checked
 end


 def visit_description_page(course)
   visit provider_recruitment_cycle_course_path(
     provider.provider_code,
     course.recruitment_cycle.year,
     course.course_code,
   )
 end

 def visit_gcse_requirements_page
   visit gcse_requirements_provider_recruitment_cycle_course_path(
     provider.provider_code,
     course2.recruitment_cycle.year,
     course2.course_code,
   )
 end
end
