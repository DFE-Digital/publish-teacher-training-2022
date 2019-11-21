class PreviousCourseCreationStepService
  def execute(current_step:, current_provider:)
    case current_step
    when :level
      :courses_list
    when :subjects
      :level
    when :age_range
      :subjects
    when :outcome
      :age_range
    when :apprenticeship
      :outcome
    when :fee_or_salary
      :outcome
    when :location
      :full_or_part_time
    when :full_or_part_time
      handle_full_or_part_time(current_provider)
    when :entry_requirements
      handle_entry_requirements(current_provider)
    when :accredited_body
      handle_accredited_body(current_provider)
    when :applications_open
      :entry_requirements
    when :start_date
      :applications_open
    end
  end

private

  def handle_full_or_part_time(current_provider)
    if current_provider.accredited_body?
      :apprenticeship
    else
      :fee_or_salary
    end
  end

  def handle_accredited_body(current_provider)
    if current_provider.sites.count > 1
      :location
    else
      :full_or_part_time
    end
  end

  def handle_entry_requirements(current_provider)
    return :accredited_body unless current_provider.accredited_body?

    if current_provider.sites.count > 1
      :location
    else
      :full_or_part_time
    end
  end
end
