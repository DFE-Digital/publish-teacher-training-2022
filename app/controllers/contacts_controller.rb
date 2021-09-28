class ContactsController < ApplicationController
  def edit
    contact
  end

  def update
    if contact.update(contact_params)
      redirect_to provider_ucas_contacts_path(provider_code: params[:provider_code])
    else
      render :edit
    end
  end

private

  def provider
    raise "missing provider code" unless params[:provider_code]

    @provider ||= Provider
                      .includes(:contacts)
                      .where(recruitment_cycle_year: Settings.current_cycle)
                      .find(params[:provider_code])
                      .first
  end

  def contact
    @contact ||= provider.contacts.find { |contact| contact.id == params[:id] }
  end

  def contact_params
    params.require(:contact)
      .permit(:id, :name, :email, :telephone, :permission_given)
  end
end
