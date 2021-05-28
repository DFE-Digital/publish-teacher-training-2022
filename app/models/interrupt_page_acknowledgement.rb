class InterruptPageAcknowledgement < Base
  belongs_to :recruitment_cycle, param: :recruitment_cycle_year
  belongs_to :user
end
