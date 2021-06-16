class ProviderVisaForm
  include ActiveModel::Model

  attr_reader :can_sponsor_skilled_worker_visa, :can_sponsor_student_visa

  validates :can_sponsor_skilled_worker_visa, inclusion: { in: [true, false], message: "Select if you can sponsor Skilled Worker visas" }
  validates :can_sponsor_student_visa, inclusion: { in: [true, false], message: "Select if you can sponsor Student visas" }

  def save(provider)
    if valid?
      provider.update(
        can_sponsor_skilled_worker_visa: can_sponsor_skilled_worker_visa,
        can_sponsor_student_visa: can_sponsor_student_visa,
      )
    end
  end

  def can_sponsor_student_visa=(value)
    @can_sponsor_student_visa = ActiveModel::Type::Boolean.new.cast(value)
  end

  def can_sponsor_skilled_worker_visa=(value)
    @can_sponsor_skilled_worker_visa = ActiveModel::Type::Boolean.new.cast(value)
  end
end
