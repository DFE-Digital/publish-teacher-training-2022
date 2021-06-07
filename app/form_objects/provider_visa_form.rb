class ProviderVisaForm
  include ActiveModel::Model

  attr_accessor :can_sponsor_skilled_worker_visa, :can_sponsor_student_visa

  validates :can_sponsor_skilled_worker_visa, inclusion: { in: [true, false], message: "Select whether provider sponsors skilled worker visas" }
  validates :can_sponsor_student_visa, inclusion: { in: [true, false],  message: "Select whether provider sponsors student visas" }

  def save
  end
end