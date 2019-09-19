describe NextCourseCreationStepService do
  let(:service) { described_class.new }

  shared_examples "next step" do
    it "Returns the correct next step" do
      next_step = service.execute(current_step: current_step)
      expect(next_step).to eq(expected_next_step)
    end
  end

  context "SCITT Provider" do
    context "Current step: Level" do
      let(:current_step) { :level }
      let(:expected_next_step) { :outcome }

      include_examples "next step"
    end

    context "Current step: Outcome" do
      let(:current_step) { :outcome }
      let(:expected_next_step) { :apprenticeship }

      include_examples "next step"
    end

    context "Current step: Apprenticeship" do
      let(:current_step) { :apprenticeship }
      let(:expected_next_step) { :full_or_part_time }

      include_examples "next step"
    end

    context "Current step: Full or part time" do
      let(:current_step) { :full_or_part_time }
      let(:expected_next_step) { :location }

      include_examples "next step"
    end

    context "Current step: Locations" do
      let(:current_step) { :location }
      let(:expected_next_step) { :entry_requirements }

      include_examples "next step"
    end

    context "Current step: Entry requirements" do
      let(:current_step) { :entry_requirements }
      let(:expected_next_step) { :applications_open }

      include_examples "next step"
    end

    context "Current step: Applications open" do
      let(:current_step) { :applications_open }
      let(:expected_next_step) { :start_date }

      include_examples "next step"
    end

    context "Current step: Start date" do
      let(:current_step) { :start_date }
      let(:expected_next_step) { :confirmation }

      include_examples "next step"
    end
  end
end
