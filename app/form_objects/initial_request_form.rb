class InitialRequestForm
  include ActiveModel::Model

  attr_accessor :training_provider_code, :training_provider_query

  def add_no_results_error
    errors.add(
      :training_provider_query,
      "We couldn't find this organisation - please check your information and try again.
                To add a new organisation to Publish, contact #{Settings.service_support.contact_email_address}.",
    )
  end

  def add_no_search_query_error
    errors.add(:training_provider_query, "You need to add some information")
  end
end
