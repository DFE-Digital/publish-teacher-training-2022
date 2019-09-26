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
    path = provider_recruitment_cycle_path(@provider.provider_code, @recruitment_cycle.year)
    provider_breadcrumb << [@recruitment_cycle.title, path]
  end

  def courses_breadcrumb
    path = provider_recruitment_cycle_courses_path(@provider.provider_code)
    recruitment_cycle_breadcrumb << ["Courses", path]
  end

  def course_breadcrumb
    path = provider_recruitment_cycle_course_path(
      @provider.provider_code,
      course.recruitment_cycle_year,
      course.course_code,
    )
    courses_breadcrumb << [course.name_and_code, path]
  end

  def sites_breadcrumb
    path = provider_recruitment_cycle_sites_path(@provider.provider_code, @recruitment_cycle.year)
    recruitment_cycle_breadcrumb << ["Locations", path]
  end

  def organisation_details_breadcrumb
    path = details_provider_recruitment_cycle_path(@provider.provider_code, @recruitment_cycle.year)
    recruitment_cycle_breadcrumb << ["About your organisation", path]
  end

  def edit_site_breadcrumb
    path = edit_provider_recruitment_cycle_site_path(@provider.provider_code, @site.recruitment_cycle_year, @site.id)
    sites_breadcrumb << [@site_name_before_update, path]
  end

  def new_site_breadcrumb
    path = new_provider_recruitment_cycle_site_path(@provider.provider_code)
    sites_breadcrumb << ["Add a location", path]
  end
end
