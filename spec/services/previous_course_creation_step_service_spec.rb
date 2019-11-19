describe PreviousCourseCreationStepService do
  let(:service) { described_class.new }

  shared_examples "previous step" do
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
      let(:current_step) { :level }
      let(:expected_previous_step) { :courses_list }

      include_examples "previous step"
    end

    context "Current step: Subjects" do
      let(:current_step) { :subjects }
      let(:expected_previous_step) { :level }

      include_examples "previous step"
    end

    context "Current step: Age Range" do
      let(:current_step) { :age_range }
      let(:expected_previous_step) { :subjects }

      include_examples "previous step"
    end

    context "Current step: Outcome" do
      let(:current_step) { :outcome }
      let(:expected_previous_step) { :age_range }

      include_examples "previous step"
    end

    context "Current step: Outcome" do
      let(:current_step) { :outcome }
      let(:expected_previous_step) { :age_range }

      include_examples "previous step"
    end

    context "current step: location" do
      let(:current_step) { :location }
      let(:expected_previous_step) { :full_or_part_time }

      include_examples "previous step"
    end

    context "current step: Applications open" do
      let(:current_step) { :applications_open }
      let(:expected_previous_step) { :entry_requirements }

      include_examples "previous step"
    end

    context "current step: Start date" do
      let(:current_step) { :start_date }
      let(:expected_previous_step) { :applications_open }

      include_examples "previous step"
    end
  end

  context "Accredited bodies" do
    let(:provider) { build(:provider, accredited_body?: true) }

    context "Current step: Apprenticeship" do
      let(:current_step) { :apprenticeship }
      let(:expected_previous_step) { :outcome }

      include_examples "previous step"
    end

    context "Current step: Full or part time" do
      let(:current_step) { :full_or_part_time }
      let(:expected_previous_step) { :apprenticeship }

      include_examples "previous step"
    end

    context "With a single site" do
      let(:provider) { build(:provider, accredited_body?: true, sites: [build(:site)]) }

      context "Current step: Entry requirements" do
        let(:current_step) { :entry_requirements }
        let(:expected_previous_step) { :full_or_part_time }

        include_examples "previous step"
      end
    end

    context "With multiple sites" do
      let(:provider) { build(:provider, accredited_body?: true, sites: [build(:site), build(:site)]) }

      context "Current step: Entry requirements" do
        let(:current_step) { :entry_requirements }
        let(:expected_previous_step) { :location }

        include_examples "previous step"
      end
    end
  end

  context "Non-accredited bodies" do
    let(:provider) { build(:provider, accredited_body?: false) }

    context "Current step: Fee or Salary" do
      let(:current_step) { :fee_or_salary }
      let(:expected_previous_step) { :outcome }

      include_examples "previous step"
    end

    context "Current step: Full or part time" do
      let(:current_step) { :full_or_part_time }
      let(:expected_previous_step) { :fee_or_salary }

      include_examples "previous step"
    end

    context "Current step: Entry requirements" do
      let(:current_step) { :entry_requirements }
      let(:expected_previous_step) { :accredited_body }

      include_examples "previous step"
    end

    context "With a single site" do
      let(:provider) { build(:provider, accredited_body?: true, sites: [build(:site)]) }

      context "Current step: Accredited Body" do
        let(:current_step) { :accredited_body }
        let(:expected_previous_step) { :full_or_part_time }

        include_examples "previous step"
      end
    end

    context "With a multiple sites" do
      let(:provider) { build(:provider, accredited_body?: true, sites: [build(:site), build(:site)]) }

      context "Current step: Accredited Body" do
        let(:current_step) { :accredited_body }
        let(:expected_previous_step) { :location }

        include_examples "previous step"
      end
    end
  end

private

  def execute(current_step:, current_provider:)
    case current_step
    when :level
      :subjects
    when :subjects
      :age_range
    when :age_range
      :outcome
    when :outcome
      handle_outcome(current_provider)
    when :fee_or_salary
      :full_or_part_time
    when :apprenticeship
      :full_or_part_time
    when :full_or_part_time
      :location
    when :location
      handle_location(current_provider)
    when :accredited_body
      :entry_requirements
    when :entry_requirements
      :applications_open
    when :applications_open
      :start_date
    when :start_date
      :confirmation
    end
  end

  def handle_outcome(provider)
    if provider.accredited_body?
      :apprenticeship
    else
      :fee_or_salary
    end
  end

  def handle_location(provider)
    if provider.accredited_body?
      :entry_requirements
    else
      :accredited_body
    end
  end
end
