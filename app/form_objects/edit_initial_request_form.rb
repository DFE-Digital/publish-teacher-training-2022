class EditInitialRequestForm
  include ActiveModel::Model

  attr_accessor :request_type, :number_of_places

  validates :request_type, presence: { message: "Select one option" }
  validate :selected_number_of_places

  def selected_number_of_places
    return if number_of_places.nil?

    errors.add(:number_of_places, "You must enter a number") unless number_of_places_valid?
  end

  def number_of_places_valid?
    !number_of_places.empty? &&
      /\A\d+\z/.match?(number_of_places) &&
      number_of_places.to_i.positive?
  end

  def selected_request_type
    errors.add(:request_type, "Select one option") unless number_of_places.present? || request_type_valid?
  end

  def request_type_valid?
    request_type == AllocationsView::RequestType::INITIAL || AllocationsView::RequestType::DECLINED
  end
end
