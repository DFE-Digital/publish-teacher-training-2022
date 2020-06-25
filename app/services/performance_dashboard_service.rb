class PerformanceDashboardService
  include ActionView::Helpers::NumberHelper

  class << self
    def call(*args)
      new(*args).call
    end
  end

  def initialize; end

  def call
    fetch_data = Faraday.get("#{Settings.manage_backend.base_url}/reporting.json")
    @response = JSON.parse(fetch_data.body)
    self
  rescue StandardError
    false
  end

  def total_providers
    number_with_delimiter(@response["providers"]["total"]["all"])
  end

  def total_courses
    number_with_delimiter(@response["courses"]["total"]["all_findable"])
  end

  def total_users
    number_with_delimiter(@response["publish"]["users"]["total"]["all"])
  end

  def total_allocations
    number_with_delimiter(@response["allocations"]["current"]["total"]["allocations"])
  end
end
