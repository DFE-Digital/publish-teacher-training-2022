class DegreePreviewComponent < ViewComponent::Base
  include ApplicationHelper
  attr_reader :course

  def initialize(course:)
    @course = course
  end

private

  def subject_name(course)
    case course.subjects.count
    when 1
      course.subjects.first.subject_name
    when 2
      course.subjects.first.subject_name + " or " + course.subjects.last.subject_name
    else
      course.name
    end
  end

  def degree_grade_content(course)
    case course.degree_grade
    when "two_one"
      "An undergraduate degree at class 2:1 or above, or equivalent."
    when "two_two"
      "An undergraduate degree at class 2:2 or above, or equivalent."
    when "third_class"
      "An undergraduate degree, or equivalent. This should be an honours degree (Third or above), or equivalent."
    when "not_required"
      "An undergraduate degree, or equivalent."
    end
  end
end
