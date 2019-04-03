module CourseHelper
  def course_has_unpublished_changes(course)
    course.attributes[:content_status] == "published_with_unpublished_changes"
  end

  def course_content_tag_content(course)
    {
      "published" => "Published",
      "empty" => "Empty",
      "draft" => "Draft",
      "published_with_unpublished_changes" => "Published *"
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
end
