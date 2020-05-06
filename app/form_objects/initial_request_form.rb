class InitialRequestForm
  include ActiveModel::Model

  attr_accessor :training_provider_code, :training_provider_query

  def add_no_results_error
    errors.add(:training_provider_query, "We couldn't find this provider, please check your input and try again")
  end
end
