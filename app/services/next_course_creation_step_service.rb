class NextCourseCreationStepService
  def execute(current_step:)
    case current_step
    when :level
      :age_range
    when :age_range
      :outcome
    when :outcome
      :apprenticeship
    when :apprenticeship
      :full_or_part_time
    when :full_or_part_time
      :location
    when :location
      :entry_requirements
    when :entry_requirements
      :applications_open
    when :applications_open
      :start_date
    when :start_date
      :confirmation
    end
  end
end
