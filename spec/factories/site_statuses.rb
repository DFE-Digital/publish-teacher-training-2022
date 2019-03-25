FactoryBot.define do
  factory :site_status, class: Hash do
    publish { 'N' }
    vac_status { :full_time_vacancies }
    status { 'running' }

    initialize_with do
      {
        "id" => 1,
        "attributes" => attributes,
        "type" => "site_statuses",
      }
    end
  end
end
