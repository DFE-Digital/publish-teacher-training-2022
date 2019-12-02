describe PreviousCourseCreationStepService do
  let(:service) { described_class.new }

  shared_examples "previous step" do |current_step, expected_previous_step|
    it "Returns the correct previous step" do
      previous_step = service.execute(
        current_step: current_step,
        current_provider: provider,
      )
      expect(previous_step).to eq(expected_previous_step)
    end
  end

  context "All providers" do
    let(:provider) { build(:provider) }

    context "Current step: Level" do
      include_examples "previous step", :level, :courses_list
    end

    context "Current step: Subjects" do
      include_examples "previous step", :subjects, :level
    end

    context "Current step: Age Range" do
      include_examples "previous step", :age_range, :subjects
    end

    context "Current step: Outcome" do
      include_examples "previous step", :outcome, :age_range
    end

    context "current step: location" do
      include_examples "previous step", :location, :full_or_part_time
    end

    context "current step: Applications open" do
      include_examples "previous step", :applications_open, :entry_requirements
    end

    context "current step: Start date" do
      include_examples "previous step", :start_date, :applications_open
    end
  end

  context "Accredited bodies" do
    let(:provider) { build(:provider, accredited_body?: true) }

    context "Current step: Apprenticeship" do
      include_examples "previous step", :apprenticeship, :outcome
    end

    context "Current step: Full or part time" do
      include_examples "previous step", :full_or_part_time, :apprenticeship
    end

    context "With a single site" do
      let(:provider) { build(:provider, accredited_body?: true, sites: [build(:site)]) }

      context "Current step: Entry requirements" do
        include_examples "previous step", :entry_requirements, :full_or_part_time
      end
    end

    context "With multiple sites" do
      let(:provider) { build(:provider, accredited_body?: true, sites: [build(:site), build(:site)]) }

      context "Current step: Entry requirements" do
        let(:current_step) { :entry_requirements }
        let(:expected_previous_step) { :location }

        include_examples "previous step", :entry_requirements, :location
      end
    end
  end

  context "Non-accredited bodies" do
    let(:provider) { build(:provider, accredited_body?: false) }

    context "Current step: Fee or Salary" do
      include_examples "previous step", :fee_or_salary, :outcome
    end

    context "Current step: Full or part time" do
      include_examples "previous step", :full_or_part_time, :fee_or_salary
    end

    context "Current step: Entry requirements" do
      include_examples "previous step", :entry_requirements, :accredited_body
    end

    context "With a single site" do
      let(:provider) { build(:provider, accredited_body?: true, sites: [build(:site)]) }

      context "Current step: Accredited Body" do
        include_examples "previous step", :accredited_body, :full_or_part_time
      end
    end

    context "With a multiple sites" do
      let(:provider) { build(:provider, accredited_body?: true, sites: [build(:site), build(:site)]) }

      context "Current step: Accredited Body" do
        include_examples "previous step", :accredited_body, :location
      end
    end
  end
end
