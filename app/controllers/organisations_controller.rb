class OrganisationsController < ApplicationController
  def index
    @organisations = Organisation
      .includes(:providers, :users)
      .all
      .sort_by(&:name)
  end

  def index_without_active_users
    @organisations = Organisation
      .includes(:providers, :users)
      .left_outer_joins(:users)
      .group("organisation.id")
      .having('count("user".welcome_email_date_utc) = 0')

    render :index
  end
end
