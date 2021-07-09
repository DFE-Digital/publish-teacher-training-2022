class Site < Base
  URN_2022_REQUIREMENTS_REQUIRED_FROM = 2022

  belongs_to :recruitment_cycle, through: :provider, param: :recruitment_cycle_year
  belongs_to :provider, param: :provider_code
  has_one :site_status

  properties :code, :location_name, :address1, :address2, :address3, :urn
  properties :address4, :postcode, :latitude, :longitude

  REGIONS = [
    ["London", :london],
    ["South East", :south_east],
    ["South West", :south_west],
    ["Wales", :wales],
    ["West Midlands", :west_midlands],
    ["East Midlands", :east_midlands],
    ["Eastern", :eastern],
    ["North West", :north_west],
    ["Yorkshire and the Humber", :yorkshire_and_the_humber],
    ["North East", :north_east],
    ["Scotland", :scotland],
    ["No Region", :no_region],
  ].freeze

  def full_address
    [address1, address2, address3, address4, postcode].select(&:present?).join(", ")
  end
end
