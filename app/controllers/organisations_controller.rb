class OrganisationsController < ApplicationController
  rescue_from "Pagy::OverflowError" do |_exception|
    raise ActionController::RoutingError, "Not Found"
  end

  def index
    page = (params[:page] || 1).to_i
    per_page = 10

    @organisations = Organisation
      .order(:name)
      .includes(:providers, :users)
      .page(page)

    @pagy = Pagy.new(count: @organisations.meta.count, page: page, items: per_page)
  end
end
