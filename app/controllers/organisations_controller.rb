class OrganisationsController < ApplicationController
  def index
    @organisations = Organisation
      .includes(:providers, :users)
      .all
      .sort_by(&:name)
  end
end
