class Allocation < Base
  properties :number_of_places

  def has_places?
    number_of_places.positive?
  end
end
