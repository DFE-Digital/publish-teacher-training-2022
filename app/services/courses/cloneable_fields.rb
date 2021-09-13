module Courses
  module CloneableFields
    GCSE = [
      ["Accept pending GCSE", "accept_pending_gcse"],
      ["Accept GCSE equivalency", "accept_gcse_equivalency"],
      ["Accept English GCSE equivalency", "accept_english_gcse_equivalency"],
      ["Accept Maths GCSE equivalency", "accept_maths_gcse_equivalency"],
      ["Additional GCSE equivalencies", "additional_gcse_equivalencies"],
    ].freeze

    SUBJECT_REQUIREMENTS = [
      ["Additional degree subject requirements", "additional_degree_subject_requirements"],
      ["Degree subject requirements", "degree_subject_requirements"],
    ].freeze

    ABOUT = [
      ["About the course", "about_course"],
      ["Interview process", "interview_process"],
      ["How school placements work", "how_school_placements_work"],
    ].freeze

    FEES = [
      ["Course length", "course_length"],
      ["Fee for UK students", "fee_uk_eu"],
      ["Fee for international students", "fee_international"],
      ["Fee details", "fee_details"],
      ["Financial support", "financial_support"],
    ].freeze

    SALARY = [
      ["Course length", "course_length"],
      ["Salary details", "salary_details"],
    ].freeze

    POST_2022_CYCLE_REQUIREMENTS = [
      ["Personal qualities", "personal_qualities"],
      ["Other requirements", "other_requirements"],
    ].freeze

    PRE_2022_CYCLE_REQUIREMENTS = [
      ["Qualifications needed", "required_qualifications"],
      ["Personal qualities", "personal_qualities"],
      ["Other requirements", "other_requirements"],
    ].freeze
  end
end
