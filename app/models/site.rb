class Site < Base
  has_one :site_status
  belongs_to :provider
end
