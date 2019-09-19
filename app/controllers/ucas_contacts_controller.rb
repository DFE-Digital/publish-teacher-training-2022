class UcasContactsController < ApplicationController
  def index
    @provider = Provider
      .where(recruitment_cycle_year: Settings.current_cycle)
      .find(params[:code])
      .first
  end
end
