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
    email = provider_params["application_alert_contact"]
    email = nil if email.blank?
    email_changed = @provider.application_alert_contact != email
    permission_given = provider_params["share_with_ucas_permission"] == "1"
    require_permission = !email.nil? && email_changed

    if require_permission && !permission_given
      @errors = { share_with_ucas_permission: ["Please give permission to share this email address with UCAS"] }
      @provider.application_alert_contact = provider_params["application_alert_contact"]
      @provider.send_application_alerts = provider_params["send_application_alerts"]
      render :alerts
    else
      @provider.update(
        send_application_alerts: provider_params["send_application_alerts"],
        application_alert_contact: email,
      )
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
