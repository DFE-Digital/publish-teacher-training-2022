require "rails_helper"

describe "Courses", type: :request do
  describe "GET fees" do
    let(:current_recruitment_cycle) { build(:recruitment_cycle) }
    let(:course) do
      build :course,
            name: "English",
            course_code: "EN01",
            provider: provider,
            include_nulls: [:accrediting_provider],
            recruitment_cycle: current_recruitment_cycle
    end
    let(:provider) { build(:provider, accredited_body?: true, provider_code: "A0") }

    let(:course_1) { build :course, name: "English", course_code: "EN01", include_nulls: [:accrediting_provider] }
    let(:course_2) do
      build :course,
            name: "Biology",
            include_nulls: [:accrediting_provider],
            course_length: "TwoYears",
            provider: provider,
            fee_uk_eu: 9500,
            fee_international: 1200,
            fee_details: "Some information about the fees",
            financial_support: "Some information about the finance support"
    end
    let(:course_3) do
      build :course,
            name: "Chemistry",
            provider: provider,
            include_nulls: [:accrediting_provider],
            fee_details: "Course 3 fees",
            financial_support: "Course 3 financial support"
    end
    let(:courses)             { [course_1, course_2, course_3] }
    let(:provider2)           { build(:provider, courses: courses, accredited_body?: true, provider_code: "A0") }
    let(:provider_2_response) { provider2.to_jsonapi(include: %i[courses accrediting_provider]) }

    before do
      stub_omniauth
      get(auth_dfe_callback_path)
      stub_api_v2_resource(current_recruitment_cycle)
      stub_api_v2_resource(course, include: "subjects,sites,provider.sites,accrediting_provider")
      stub_api_v2_resource(course_2, include: "subjects,sites,provider.sites,accrediting_provider")
      stub_api_v2_resource(course_3, include: "subjects,sites,provider.sites,accrediting_provider")
      stub_api_v2_resource(provider)
      stub_api_v2_resource(provider2, include: "courses.accrediting_provider")
    end

    context "Default recruitment cycle" do
      it "should redirect to new courses#fees route" do
        get("/organisations/#{provider.provider_code}/courses/#{course.course_code}/fees")
        expect(response).to redirect_to(fees_provider_recruitment_cycle_course_path(provider.provider_code, Settings.current_cycle, course.course_code))
      end
    end

    it "renders the course length and fees" do
      get(fees_provider_recruitment_cycle_course_path(
            provider.provider_code,
            course.recruitment_cycle_year,
            course.course_code,
          ))

      expect(response.body).to include(
        "#{course.name} (#{course.course_code})",
      )
      expect(response.body).to include(
        "Course length and fees",
      )
      expect(response.body).to_not include(
        "Your changes are not yet saved",
      )
    end

    context "with copy_from parameter" do
      it "renders the course length and fees with data from chosen course" do
        get(fees_provider_recruitment_cycle_course_path(
              provider.provider_code,
              course.recruitment_cycle_year,
              course.course_code,
              params: { copy_from: course_2.course_code },
            ))

        expect(response.body).to include(
          "Your changes are not yet saved",
        )
        expect(response.body).to include(
          course_2.course_length,
        )
        expect(response.body).to include(
          course_2.fee_uk_eu.to_s,
        )
        expect(response.body).to include(
          course_2.fee_international.to_s,
        )
        expect(response.body).to include(
          course_2.fee_details,
        )
        expect(response.body).to include(
          course_2.financial_support,
        )
      end

      it "doesn’t blank fields that were empty in the copied source" do
        get(fees_provider_recruitment_cycle_course_path(
              provider.provider_code,
              course_2.recruitment_cycle_year,
              course_2.course_code,
              params: { copy_from: course_3.course_code },
            ))

        expect(response.body).to include(
          "Your changes are not yet saved",
        )

        original_course_details = [
          course_2.course_length,
          course_2.fee_uk_eu.to_s,
          course_2.fee_international.to_s,
        ]

        copied_course_details = [
          course_3.fee_details,
          course_3.financial_support,
        ]

        (original_course_details + copied_course_details).each do |value|
          expect(response.body).to include(value)
        end
      end
    end
  end
end
