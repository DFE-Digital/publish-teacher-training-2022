class GcsePreviewComponent < ViewComponent::Base
  attr_reader :course

  def initialize(course:)
    @course = course
  end

private

  def required_gcse_content(course)
    case course.level
    when "primary"
      "Grade 4 (C) or above in English, maths and science"
    when "secondary"
      "Grade 4 (C) or above in English and maths"
    end
  end

  def pending_gcse_content(course)
    if course.accept_pending_gcse.present?
      "Candidates with pending GCSEs will be considered"
    else
      "Candidates with pending GCSEs will not be considered"
    end
  end

  def gcse_equivalency_content(course)
    equivalencies = []

    if course.accept_english_gcse_equivalency.present?
      equivalencies << "english"
    end

    if course.accept_maths_gcse_equivalency.present?
      equivalencies << "maths"
    end

    if course.accept_science_gcse_equivalency.present?
      equivalencies << "science"
    end

    case equivalencies.count
    when 1
      "Equivalency tests will be accepted in #{equivalencies[0].capitalize}"
    when 2
      "Equivalency tests will be accepted in #{equivalencies[0].capitalize} and #{equivalencies[1]}"
    when 3
      "Equivalency tests will be accepted in #{equivalencies[0].capitalize}, #{equivalencies[1]} and #{equivalencies[2]}"
    end
  end
end
