class DegreeRowContentComponent < ViewComponent::Base
  attr_reader :course

  def initialize(course:)
    @course = course
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
