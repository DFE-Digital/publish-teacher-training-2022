class InitialRequestForm
  include ActiveModel::Model

  attr_accessor :training_provider_code, :training_provider_query

  validates :training_provider_code, presence: { message: "Select or search for an organisation" }
  validates :training_provider_query, presence: { message: "You need to add some information", if: :provider_search? }
  validates :training_provider_query, length: { minimum: 2, message: "Please enter a minimum of two characters", if: :provider_search? }

  def add_no_results_error
    errors.add(
      :training_provider_query,
      "We could not find this organisation - please check your information and try again.",
    )
  end

private

  def provider_search?
    training_provider_code == "-1"
  end
end
