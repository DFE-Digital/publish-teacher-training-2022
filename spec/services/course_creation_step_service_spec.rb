require "rails_helper"

describe CourseCreationStepService do
  let(:service) { described_class.new }
  let(:course) { build(:course, level: level, provider: provider) }
  let(:provider) { build(:provider) }

  shared_examples "next step" do |current_step, expected_next_step|
    it "Returns the correct next step" do
      next_step = service.execute(
        current_step: current_step,
        course: course,
      )[:next]
      expect(next_step).to eq(expected_next_step)
    end
  end

  shared_examples "previous step" do |current_step, expected_prev_step|
    it "Returns the correct previous step" do
      prev_step = service.execute(
        current_step: current_step,
        course: course,
      )[:previous]
      expect(prev_step).to eq(expected_prev_step)
    end
  end

  context "next steps" do
    context "School Direct" do
      let(:level) { "primary" }
      let(:sites) { [build(:site), build(:site)] }
      let(:provider) { build(:provider, accredited_body?: false, sites: sites) }

      context "Current step: Subjects" do
        include_examples "next step", :subjects, :modern_languages
      end

      context "Current step: Modern languages" do
        include_examples "next step", :modern_languages, :age_range
      end

      context "Current step: Outcome" do
        include_examples "next step", :outcome, :fee_or_salary
      end

      context "Current step: Fee or salary" do
        include_examples "next step", :fee_or_salary, :full_or_part_time
      end

      context "Current step: Full or part time" do
        include_examples "next step", :full_or_part_time, :location
      end

      context "Current step: Location" do
        include_examples "next step", :location, :accredited_body
      end

      context "Current step: Accredited body" do
        include_examples "next step", :accredited_body, :entry_requirements
      end

      context "Current step: Applications open" do
        include_examples "next step", :applications_open, :start_date
      end

      context "Current step: Start date" do
        include_examples "next step", :start_date, :confirmation
      end
    end

    context "SCITT Provider" do
      let(:level) { "primary" }
      let(:sites) { [build(:site), build(:site)] }
      let(:provider) { build(:provider, accredited_body?: true, sites: sites) }

      context "Current step: Subjects" do
        include_examples "next step", :subjects, :modern_languages
      end

      context "Current step: Modern languages" do
        include_examples "next step", :modern_languages, :age_range
      end

      context "Current step: Level" do
        include_examples "next step", :level, :subjects
      end

      context "Current step: Age range" do
        include_examples "next step", :age_range, :outcome
      end

      context "Current step: Outcome" do
        include_examples "next step", :outcome, :apprenticeship
      end

      context "Current step: Apprenticeship" do
        include_examples "next step", :apprenticeship, :full_or_part_time
      end

      context "Current step: Full or part time" do
        include_examples "next step", :full_or_part_time, :location
      end

      context "Current step: Locations" do
        include_examples "next step", :location, :entry_requirements
      end

      context "Current step: Entry requirements" do
        include_examples "next step", :entry_requirements, :applications_open
      end

      context "Current step: Applications open" do
        include_examples "next step", :applications_open, :start_date
      end

      context "Current step: Start date" do
        include_examples "next step", :start_date, :confirmation
      end
    end

    context "Further education" do
      let(:sites) { [build(:site), build(:site)] }
      let(:provider) { build(:provider, sites: sites) }
      let(:level) { "further_education" }

      context "Current step: Level" do
        include_examples "next step", :level, :outcome
      end

      context "Current step: Outcome" do
        include_examples "next step", :outcome, :full_or_part_time
      end

      context "Current step: Full or part time" do
        include_examples "next step", :full_or_part_time, :location
      end

      context "Current step: Location" do
        include_examples "next step", :location, :applications_open
      end

      context "Current step: Applications open" do
        include_examples "next step", :applications_open, :start_date
      end

      context "Current step: Start date" do
        include_examples "next step", :start_date, :confirmation
      end
    end
  end

  context "previous steps" do
    context "School Direct" do
      let(:level) { "primary" }
      let(:provider) { build(:provider, accredited_body?: false) }

      context "Current step: Level" do
        include_examples "previous step", :level, :courses_list
      end

      context "Current step: Modern languages" do
        include_examples "previous step", :modern_languages, :subjects
      end

      context "Current step: Age range" do
        include_examples "previous step", :age_range, :modern_languages
      end

      context "Current step: Fee or salary" do
        include_examples "previous step", :fee_or_salary, :outcome
      end

      context "Current step: Full or part time" do
        include_examples "previous step", :full_or_part_time, :fee_or_salary
      end

      context "Current step: Accredited body" do
        include_examples "previous step", :accredited_body, :location
      end

      context "Current step: Entry requirements" do
        include_examples "previous step", :entry_requirements, :accredited_body
      end

      context "Current step: Start date" do
        include_examples "previous step", :start_date, :applications_open
      end

      context "Current step: Confirmation" do
        include_examples "previous step", :confirmation, :start_date
      end
    end

    context "SCITT Provider" do
      let(:level) { "primary" }
      let(:provider) { build(:provider, accredited_body?: true) }

      context "Current step: Level" do
        include_examples "previous step", :level, :courses_list
      end

      context "Current step: Subjects" do
        include_examples "previous step", :subjects, :level
      end

      context "Current step: Modern languages" do
        include_examples "previous step", :modern_languages, :subjects
      end

      context "Current step: Age range" do
        include_examples "previous step", :age_range, :modern_languages
      end

      context "Current step: Outcome" do
        include_examples "previous step", :outcome, :age_range
      end

      context "Current step: Apprenticeship" do
        include_examples "previous step", :apprenticeship, :outcome
      end

      context "Current step: Full or part time" do
        include_examples "previous step", :full_or_part_time, :apprenticeship
      end

      context "Current step: Location" do
        include_examples "previous step", :location, :full_or_part_time
      end

      context "Current step: Entry requirements" do
        include_examples "previous step", :entry_requirements, :location
      end

      context "Current step: Applications open" do
        include_examples "previous step", :applications_open, :entry_requirements
      end

      context "Current step: Start date" do
        include_examples "previous step", :start_date, :applications_open
      end

      context "Current step: confirmation" do
        include_examples "previous step", :confirmation, :start_date
      end
    end

    context "Further education" do
      let(:provider) { build(:provider) }
      let(:level) { "further_education" }

      context "Current step: Level" do
        include_examples "previous step", :level, :courses_list
      end

      context "Current step: Outcome" do
        include_examples "previous step", :outcome, :level
      end

      context "Current step: Full or part time" do
        include_examples "previous step", :full_or_part_time, :outcome
      end

      context "Current step: Location" do
        include_examples "previous step", :location, :full_or_part_time
      end

      context "Current step: Applications open" do
        include_examples "previous step", :applications_open, :location
      end

      context "Current step: Start date" do
        include_examples "previous step", :start_date, :applications_open
      end

      context "Current step: Confirmation" do
        include_examples "previous step", :confirmation, :start_date
      end
    end
  end

  context "creation of course for is next cycle" do
    let(:recruitment_cycle) { build(:recruitment_cycle, :next_cycle) }
    context "next steps" do
      context "School Direct" do
        let(:level) { "primary" }
        let(:sites) { [build(:site), build(:site)] }
        let(:provider) { build(:provider, accredited_body?: false, sites: sites, recruitment_cycle: recruitment_cycle) }

        context "Current step: Subjects" do
          include_examples "next step", :subjects, :modern_languages
        end

        context "Current step: Modern languages" do
          include_examples "next step", :modern_languages, :age_range
        end

        context "Current step: Outcome" do
          include_examples "next step", :outcome, :fee_or_salary
        end

        context "Current step: Fee or salary" do
          include_examples "next step", :fee_or_salary, :full_or_part_time
        end

        context "Current step: Full or part time" do
          include_examples "next step", :full_or_part_time, :location
        end

        context "Current step: Location" do
          include_examples "next step", :location, :accredited_body
        end

        context "Current step: Accredited body" do
          include_examples "next step", :accredited_body, :applications_open
        end

        context "Current step: Applications open" do
          include_examples "next step", :applications_open, :start_date
        end

        context "Current step: Start date" do
          include_examples "next step", :start_date, :confirmation
        end
      end

      context "SCITT Provider" do
        let(:level) { "primary" }
        let(:sites) { [build(:site), build(:site)] }
        let(:provider) { build(:provider, accredited_body?: true, sites: sites, recruitment_cycle: recruitment_cycle) }

        context "Current step: Subjects" do
          include_examples "next step", :subjects, :modern_languages
        end

        context "Current step: Modern languages" do
          include_examples "next step", :modern_languages, :age_range
        end

        context "Current step: Level" do
          include_examples "next step", :level, :subjects
        end

        context "Current step: Age range" do
          include_examples "next step", :age_range, :outcome
        end

        context "Current step: Outcome" do
          include_examples "next step", :outcome, :apprenticeship
        end

        context "Current step: Apprenticeship" do
          include_examples "next step", :apprenticeship, :full_or_part_time
        end

        context "Current step: Full or part time" do
          include_examples "next step", :full_or_part_time, :location
        end

        context "Current step: Locations" do
          include_examples "next step", :location, :applications_open
        end

        context "Current step: Applications open" do
          include_examples "next step", :applications_open, :start_date
        end

        context "Current step: Start date" do
          include_examples "next step", :start_date, :confirmation
        end
      end

      context "Further education" do
        let(:sites) { [build(:site), build(:site)] }
        let(:provider) { build(:provider, sites: sites, recruitment_cycle: recruitment_cycle) }
        let(:level) { "further_education" }

        context "Current step: Level" do
          include_examples "next step", :level, :outcome
        end

        context "Current step: Outcome" do
          include_examples "next step", :outcome, :full_or_part_time
        end

        context "Current step: Full or part time" do
          include_examples "next step", :full_or_part_time, :location
        end

        context "Current step: Location" do
          include_examples "next step", :location, :applications_open
        end

        context "Current step: Applications open" do
          include_examples "next step", :applications_open, :start_date
        end

        context "Current step: Start date" do
          include_examples "next step", :start_date, :confirmation
        end
      end
    end

    context "previous steps" do
      context "School Direct" do
        let(:level) { "primary" }
        let(:provider) { build(:provider, accredited_body?: false, recruitment_cycle: recruitment_cycle) }

        context "Current step: Level" do
          include_examples "previous step", :level, :courses_list
        end

        context "Current step: Modern languages" do
          include_examples "previous step", :modern_languages, :subjects
        end

        context "Current step: Age range" do
          include_examples "previous step", :age_range, :modern_languages
        end

        context "Current step: Fee or salary" do
          include_examples "previous step", :fee_or_salary, :outcome
        end

        context "Current step: Full or part time" do
          include_examples "previous step", :full_or_part_time, :fee_or_salary
        end

        context "Current step: Accredited body" do
          include_examples "previous step", :accredited_body, :location
        end

        context "Current step: Start date" do
          include_examples "previous step", :start_date, :applications_open
        end

        context "Current step: Confirmation" do
          include_examples "previous step", :confirmation, :start_date
        end
      end

      context "SCITT Provider" do
        let(:level) { "primary" }
        let(:provider) { build(:provider, accredited_body?: true, recruitment_cycle: recruitment_cycle) }

        context "Current step: Level" do
          include_examples "previous step", :level, :courses_list
        end

        context "Current step: Subjects" do
          include_examples "previous step", :subjects, :level
        end

        context "Current step: Modern languages" do
          include_examples "previous step", :modern_languages, :subjects
        end

        context "Current step: Age range" do
          include_examples "previous step", :age_range, :modern_languages
        end

        context "Current step: Outcome" do
          include_examples "previous step", :outcome, :age_range
        end

        context "Current step: Apprenticeship" do
          include_examples "previous step", :apprenticeship, :outcome
        end

        context "Current step: Full or part time" do
          include_examples "previous step", :full_or_part_time, :apprenticeship
        end

        context "Current step: Location" do
          include_examples "previous step", :location, :full_or_part_time
        end

        context "Current step: Applications open" do
          include_examples "previous step", :applications_open, :location
        end

        context "Current step: Start date" do
          include_examples "previous step", :start_date, :applications_open
        end

        context "Current step: confirmation" do
          include_examples "previous step", :confirmation, :start_date
        end
      end

      context "Further education" do
        let(:provider) { build(:provider, recruitment_cycle: recruitment_cycle) }
        let(:level) { "further_education" }

        context "Current step: Level" do
          include_examples "previous step", :level, :courses_list
        end

        context "Current step: Outcome" do
          include_examples "previous step", :outcome, :level
        end

        context "Current step: Full or part time" do
          include_examples "previous step", :full_or_part_time, :outcome
        end

        context "Current step: Location" do
          include_examples "previous step", :location, :full_or_part_time
        end

        context "Current step: Applications open" do
          include_examples "previous step", :applications_open, :location
        end

        context "Current step: Start date" do
          include_examples "previous step", :start_date, :applications_open
        end

        context "Current step: Confirmation" do
          include_examples "previous step", :confirmation, :start_date
        end
      end
    end
  end
end
