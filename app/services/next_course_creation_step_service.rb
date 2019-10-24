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
      if current_provider.accredited_body?
        :apprenticeship
      else
        :fee_or_salary
      end
    when :apprenticeship
      :full_or_part_time
    when :full_or_part_time
      :location
    when :location
      if current_provider.accredited_body?
        :entry_requirements
      else
        :accredited_body
      end
    when :entry_requirements
      :applications_open
    when :applications_open
      :start_date
    when :start_date
      :confirmation
    end
  end
end
