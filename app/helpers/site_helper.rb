module SiteHelper
  def urn_required?(recruitment_cycle_year)
    recruitment_cycle_year >= Site::URN_2022_REQUIREMENTS_REQUIRED_FROM
  end

  def new_publish_link_for(path)
    "#{Settings.new_publish_url}/publish#{path}"
  end
end
