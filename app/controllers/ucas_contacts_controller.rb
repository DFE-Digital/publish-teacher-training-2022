class UcasContactsController < ApplicationController
  def show
    provider_code = params[:provider_code]
    raise "missing provider code" unless provider_code

    @provider = Provider
      .where(recruitment_cycle_year: Settings.current_cycle)
      .find(provider_code)
      .first
  end
end
