class Site < Base
  has_one :site_status
  belongs_to :provider, param: :provider_code

  REGIONS = [
    ['No Region', :no_region],
    ['London', :london],
    ['South East', :south_east],
    ['South West', :south_west],
    ['Wales', :wales],
    ['West Midlands', :west_midlands],
    ['East Midlands', :east_midlands],
    ['Eastern', :eastern],
    ['Noth West', :north_west],
    ['Yorkshire and the Humber', :yorkshire_and_the_humber],
    ['North East', :north_east],
    ['Scotland', :scotland],
  ].freeze
end
