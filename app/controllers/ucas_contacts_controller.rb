class UcasContactsController < ApplicationController
  before_action do
    provider_code = params[:provider_code]
    raise "missing provider code" unless provider_code

    @provider = Provider
                  .where(recruitment_cycle_year: Settings.current_cycle)
                  .find(provider_code)
                  .first
  end

  def show; end

  def alerts; end

  def update_alerts
    @provider.update(provider_params)
    redirect_to provider_ucas_contacts_path(@provider.provider_code),
                flash: { success: "Your changes have been saved" }
  end

private

  def provider_params
    params.require(:provider).permit(:send_application_alerts)
  end
end
