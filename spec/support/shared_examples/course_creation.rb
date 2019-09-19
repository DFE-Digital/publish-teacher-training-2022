shared_examples_for 'a course creation page' do
  scenario "sends user to the next step page" do
    expect(next_step_page).to be_displayed(
      provider_code: provider.provider_code,
      recruitment_cycle_year: provider.recruitment_cycle_year
    )
  end

  scenario "stores the selected field" do
    query_hash = selected_fields.reduce({}) do |res, (k, v)|
      res["course[#{k}]"] = v
      res
    end

    expect(next_step_page.url_matches['query']).to eq(
      query_hash
    )
  end

  scenario "it builds the course with the selected value" do
    expect(build_course_with_selected_value_request).to have_been_made.at_least_once
  end
end
