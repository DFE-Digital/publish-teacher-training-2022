class TrainingProvider < Base
  belongs_to :recruitment_cycle, param: :recruitment_cycle_year
  belongs_to :provider, param: :provider_code
end
