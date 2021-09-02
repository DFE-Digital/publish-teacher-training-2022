class ProviderVisaForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :can_sponsor_skilled_worker_visa, :boolean
  attribute :can_sponsor_student_visa, :boolean

  validates :can_sponsor_student_visa, inclusion: { in: [true, false], message: "Select if candidates can get a Skilled Worker visa" }
  validates :can_sponsor_skilled_worker_visa, inclusion: { in: [true, false], message: "Select if candidates can get a sponsored Skilled Worker visa" }

  def save(provider)
    if valid?
      provider.update(
        can_sponsor_student_visa: can_sponsor_student_visa,
        can_sponsor_skilled_worker_visa: can_sponsor_skilled_worker_visa,
      )
    end
  end
end
