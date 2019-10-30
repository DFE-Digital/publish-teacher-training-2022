class NextCourseCreationStepService
  def execute(current_step:, current_provider:)
    case current_step
    when :level
      :subjects
    when :subjects
      :age_range
    when :age_range
      :outcome
    when :outcome
      handle_outcome(current_provider)
    when :fee_or_salary
      :full_or_part_time
    when :apprenticeship
      :full_or_part_time
    when :full_or_part_time
      :location
    when :location
      handle_location(current_provider)
    when :accredited_body
      :entry_requirements
    when :entry_requirements
      :applications_open
    when :applications_open
      :start_date
    when :start_date
      :confirmation
    end
  end

private

  def handle_outcome(provider)
    if provider.accredited_body?
      :apprenticeship
    else
      :fee_or_salary
    end
  end

  def handle_location(provider)
    if provider.accredited_body?
      :entry_requirements
    else
      :accredited_body
    end
  end
end
