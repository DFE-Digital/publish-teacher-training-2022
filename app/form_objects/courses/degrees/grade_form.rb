module Courses
  module Degrees
    class GradeForm
      include ActiveModel::Model

      attr_accessor :grade

      validates :grade, presence: { message: "Select the minimum degree classification you require" }

      def save(course)
        return false unless valid?

        course.update(degree_grade: grade)
      end

      def self.build_from_course(course)
        new(grade: course.degree_grade)
      end
    end
  end
end
