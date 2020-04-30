shared_examples_for "a course creation page" do
  scenario "sends user to the next step page" do
    expect(next_step_page).to be_displayed(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year,
    )
  end

  scenario "stores the selected field" do
    expect(URI.parse(next_step_page.current_url).query).to eq(
      selected_fields.to_query(:course),
    )
  end

  scenario "it builds the course with the selected value" do
    expect(build_course_with_selected_value_request).to have_been_made.at_least_once
  end
end
