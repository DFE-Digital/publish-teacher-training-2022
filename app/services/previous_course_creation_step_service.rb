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
      if current_provider.accredited_body?
        :apprenticeship
      else
        :fee_or_salary
      end
    when :entry_requirements
      if current_provider.accredited_body?
        if current_provider.sites.count > 1
          :location
        else
          :full_or_part_time
        end
      else
        :accredited_body
      end
    when :accredited_body
      if current_provider.sites.count > 1
        :location
      else
        :full_or_part_time
      end
    when :applications_open
      :entry_requirements
    when :start_date
      :applications_open
    end
  end
end
