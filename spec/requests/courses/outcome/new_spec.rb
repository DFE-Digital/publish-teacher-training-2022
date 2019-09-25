require "rails_helper"

describe "/organisations/:provider_code/:year/courses/:course_code/outcome/new", type: :request do
  let(:provider) { build(:provider) }
  let(:course)   { build(:course, provider: provider) }

  let(:new_outcome_page) do
    PageObjects::Page::Organisations::Courses::NewOutcomePage.new
  end

  before do
    stub_omniauth
    get(auth_dfe_callback_path)

    stub_api_v2_resource(provider)

    new_course = build(:course, :new, provider: provider)
    stub_api_v2_new_resource(new_course)
    stub_api_v2_resource_collection([course])
    stub_api_v2_build_course
  end

  it "renders the new outcome page" do
    get(new_provider_recruitment_cycle_courses_outcome_path(
          provider_code: provider.provider_code,
          recruitment_cycle_year: provider.recruitment_cycle.year,
        ))

    expect(response.status).to eq 200
    expect(response).to render_template("courses/outcome/new")
  end
end
