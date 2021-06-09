class ProviderVisaForm
  include ActiveModel::Model

  attr_accessor :can_sponsor_skilled_worker_visa, :can_sponsor_student_visa

  validates :can_sponsor_skilled_worker_visa, inclusion: { in: [true, false], message: "Select whether your provider can sponsor skilled worker visas" }
  validates :can_sponsor_student_visa, inclusion: { in: [true, false],  message: "Select whether your provider can sponsor student visas" }

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
