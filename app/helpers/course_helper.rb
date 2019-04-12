module CourseHelper
  def course_has_unpublished_changes(course)
    course.attributes[:content_status] == "published_with_unpublished_changes"
  end

  def course_content_tag_content(course)
    {
      "published" => "Published",
      "empty" => "Empty",
      "draft" => "Draft",
      "published_with_unpublished_changes" => "Published&nbsp;*"
    }[course.attributes[:content_status]]
  end

  def course_content_tag_css_class(course)
    {
      "published" => "phase-tag--published",
      "empty" => "phase-tag--no-content",
      "draft" => "phase-tag--draft",
      "published_with_unpublished_changes" => "phase-tag--published"
    }[course.attributes[:content_status]]
  end

  def course_ucas_status(course)
    {
      "running" => "Running",
      "new" => "New – not yet running",
      "not_running" => "Not running"
    }[course.attributes[:ucas_status]]
  end

  def course_outcome(course)
    course.qualifications.sort.map(&:upcase).join(' with ')
  end

  def course_study_mode(course)
    course.study_mode.humanize
  end

  def course_start_date(course)
    course.start_date.to_date.strftime("%B %Y")
  end
end
