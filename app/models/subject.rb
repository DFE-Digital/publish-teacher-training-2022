class Subject < Base
  has_many :course_subjects
  has_many :courses, through: :course_subjects

  property :type, type: :string
  property :subject_code, type: :string
  property :subject_name, type: :string
end
