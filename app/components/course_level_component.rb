class CourseLevelComponent < ViewComponent::Base
  attr_reader :course, :changeable

  def initialize(course:, changeable: false)
    @course = course
    @changeable = changeable
  end
end
