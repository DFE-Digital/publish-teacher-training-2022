class SiteStatusSerializer < JSONAPI::Serializable::Resource
  type 'site_statuses'

  has_one :site
end
