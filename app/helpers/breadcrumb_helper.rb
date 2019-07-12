module BreadcrumbHelper
  def render_breadcrumbs(type)
    render partial: "shared/breadcrumbs", locals: { items: send("#{type}_breadcrumb") }
  end

  def organisations_breadcrumb
    @has_multiple_providers ? [["Organisations", providers_path]] : []
  end

  def provider_breadcrumb
    path = provider_path(code: @provider.provider_code)
    organisations_breadcrumb << [@provider.provider_name, path]
  end

  def recruitment_cycle_breadcrumb
    if @provider.rolled_over?
      path = provider_recruitment_cycle_path(@provider.provider_code, @recruitment_cycle.year)
      provider_breadcrumb << [@recruitment_cycle.title, path]
    else
      provider_breadcrumb
    end
  end

  def courses_breadcrumb
    path = provider_recruitment_cycle_courses_path(@provider.provider_code)
    recruitment_cycle_breadcrumb << ["Courses", path]
  end

  def course_breadcrumb
    path = provider_recruitment_cycle_course_path(
      @provider.provider_code,
      course.recruitment_cycle_year,
      course.course_code
    )
    courses_breadcrumb << [course.name_and_code, path]
  end
end
