class UcasContactsController < ApplicationController
  def index
    provider_code = params[:code]
    raise "missing provider code" unless provider_code

    @provider = Provider
      .where(recruitment_cycle_year: Settings.current_cycle)
      .find(provider_code)
      .first
  end
end
