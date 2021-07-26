class DegreeRowContentComponent < ViewComponent::Base
  attr_reader :course
  attr_reader :errors

  def initialize(course:, errors: nil)
    @course = course
    @errors = errors
  end

  def inset_text_css_classes
    messages = if errors
                 errors.values.flatten
               end

    if messages&.include?("Enter degree requirements")
      "app-inset-text--narrow-border app-inset-text--error"
    else
      "app-inset-text--narrow-border app-inset-text--important"
    end
  end

private

  def degree_grade_content(course)
    case course.degree_grade
    when "two_one"
      "2:1 or above, or equivalent"
    when "two_two"
      "2:2 or above, or equivalent"
    when "third_class"
      "Third class degree or above, or equivalent"
    when "not_required"
      "An undergraduate degree, or equivalent"
    end
  end
end
