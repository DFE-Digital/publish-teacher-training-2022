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

  def course_ucas_status(course)
    {
      "running" => "Running",
      "new" => "New – not yet running",
      "not_running" => "Not running"
    }[course.attributes[:ucas_status]]
  end

  def new_course_google_form(provider)
    if provider.accredited_body?
      Settings.google_forms.new_course_for_accredited_bodies_url
    else
      Settings.google_forms.new_course_for_unaccredited_bodies_url
    end
  end

  def add_course_link(provider)
    link_to "Add a new course", new_course_google_form(provider), class: "govuk-button govuk-!-margin-bottom-2", rel: "noopener noreferrer", target: :blank
  end
end
