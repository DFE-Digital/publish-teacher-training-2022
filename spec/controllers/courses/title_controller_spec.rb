require "rails_helper"

RSpec.describe Courses::TitleController do
  let(:provider) { build(:provider) }
  let(:course) { build(:course, provider: provider) }
  let(:user) { build(:user) }
  let(:current_user) do
    {
      user_id: 1,
      uid: SecureRandom.uuid,
      info: {
        email: "dave@example.com",
      },
      admin: user.admin,
      attributes: user.attributes,
    }.with_indifferent_access
  end

  before do
    allow(controller).to receive(:current_user).and_return(current_user)
    stub_api_v2_resource(course.recruitment_cycle)
    stub_api_v2_resource(course)
  end

  describe "#edit" do
    context "when a non-admin" do
      it "is forbidden" do
        get :edit, params: {
          provider_code: provider.provider_code,
          recruitment_cycle_year: course.recruitment_cycle.year,
          code: course.course_code,
        }

        expect(response).to be_forbidden
        expect(response.body).to render_template("errors/forbidden")
      end
    end

    context "when an admin" do
      let(:user) { build(:user, :admin) }

      it "is accessible" do
        get :edit, params: {
          provider_code: provider.provider_code,
          recruitment_cycle_year: course.recruitment_cycle.year,
          code: course.course_code,
        }
        expect(response).to be_successful
      end
    end
  end

  describe "#update" do
    let(:user) { build(:user, :admin) }

    it "updates the course title" do
      stub_api_v2_resource(course, method: :patch) do |body|
        expect(body["data"]["attributes"]["name"]).to eql("new course name")
      end

      put :update, params: {
        provider_code: provider.provider_code,
        recruitment_cycle_year: course.recruitment_cycle.year,
        code: course.course_code,
        course: {
          name: "new course name",
        },
      }
    end

    context "when title is blank" do
      it "renders the form" do
        errors = {
          errors: [
            {
              "source": { "pointer": "/data/attributes/name" },
              "title": "Title issue",
              "detail": "Title cannot be blank",
            },
          ],
        }

        stub_api_v2_resource(course, jsonapi_response: errors, method: :patch)

        put :update, params: {
          provider_code: provider.provider_code,
          recruitment_cycle_year: course.recruitment_cycle.year,
          code: course.course_code,
          course: {
            name: "",
          },
        }

        expect(subject).to render_template(:edit)
      end
    end
  end
end
