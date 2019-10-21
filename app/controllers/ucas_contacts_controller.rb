class UcasContactsController < ApplicationController
  before_action do
    provider_code = params[:provider_code]
    raise "missing provider code" unless provider_code

    @provider = Provider
                  .where(recruitment_cycle_year: Settings.current_cycle)
                  .find(provider_code)
                  .first

    @provider.send_application_alerts = "none" unless @provider.send_application_alerts
  end

  def show; end

  def alerts; end

  def update_alerts
    email_changed = @provider.application_alert_contact != provider_params["application_alert_contact"]
    permission_given = params["provider"]["share_with_ucas_permission"] != "1"
    if permission_given && email_changed
      @errors = { share_with_ucas_permission: ["Please give permission to share this email with UCAS"] }
      render :alerts
    else
      @provider.update(provider_params)
      redirect_to provider_ucas_contacts_path(@provider.provider_code),
                  flash: { success: "Your changes have been saved" }
    end
  end

private

  def provider_params
    params.require(:provider)
      .permit(:send_application_alerts, :application_alert_contact, :share_with_ucas_permission)
  end
end
