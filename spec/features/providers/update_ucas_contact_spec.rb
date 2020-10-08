require "rails_helper"

feature "update ucas contact" do
  scenario "with valid params" do
    given_i_am_a_provider_user
    and_i_am_logged_in
    and_my_provider_has_ucas_contacts
    when_i_view_the_contacts
    and_i_click_the_change_link_on_the_admin_contact
    and_i_update_the_details
    then_i_am_redirected_to_the_contacts_page
    and_the_updated_details_are_visible
  end

  scenario "with invalid params" do
    given_i_am_a_provider_user
    and_i_am_logged_in
    and_my_provider_has_ucas_contacts
    when_i_view_the_contacts
    and_i_click_the_change_link_on_the_admin_contact
    and_i_update_the_details_with_invalid_params
    then_i_am_not_redirected_to_the_contacts_page
    and_an_error_message_is_displayed
  end

  def given_i_am_a_provider_user
    provider
  end

  def and_i_am_logged_in
    stub_omniauth
  end

  def and_my_provider_has_ucas_contacts
    provider.contacts = []
    contacts.each { |contact| provider.contacts << contact }
  end

  def when_i_view_the_contacts
    stub_initial_provider_request

    contacts_page.load(provider_code: provider.provider_code)
  end

  def and_i_click_the_change_link_on_the_admin_contact
    contacts_page.admin_contact.change_link.click
  end

  def and_i_update_the_details
    stub_updated_provider_request
    stub_update_request
    contacts_edit_page.name_field.set("John")
    contacts_edit_page.email_field.set("john.cleese@bbc.co.uk")
    contacts_edit_page.telephone_field.set("0790462876")
    contacts_edit_page.submit_button.click
  end

  def and_i_update_the_details_with_invalid_params
    stub_updated_provider_request
    stub_invalid_update_request
    contacts_edit_page.submit_button.click
  end

  def and_an_error_message_is_displayed
    expect(contacts_edit_page.error_message).to be_visible
  end

  def then_i_am_redirected_to_the_contacts_page
    expect(contacts_page).to be_displayed
  end

  def then_i_am_not_redirected_to_the_contacts_page
    expect(contacts_page).not_to be_displayed
  end

  def and_the_updated_details_are_visible
    expect(contacts_page.admin_contact.details).to have_content("John")
    expect(contacts_page.admin_contact.details).to have_content("john.cleese@bbc.co.uk")
    expect(contacts_page.admin_contact.details).to have_content("0790462876")
  end

  def provider
    @provider ||= build(:provider, provider_code: "A0")
  end

  def contacts
    @contacts ||= other_contacts + [admin_contact]
  end

  def admin_contact
    @admin_contact ||= build(:contact, :admin)
  end

  def updated_contacts
    @updated_contacts ||= begin
                            admin_contact.name = "John"
                            admin_contact.email = "john.cleese@bbc.co.uk"
                            admin_contact.telephone = "0790462876"
                            other_contacts + [admin_contact]
                          end
  end

  def other_contacts
    @other_contacts ||= [
      build(:contact, :utt),
      build(:contact, :web_link),
      build(:contact, :fraud),
      build(:contact, :finance),
    ]
  end

  def contacts_page
    @contacts_page ||= PageObjects::Page::Organisations::UcasContacts.new
  end

  def contacts_edit_page
    @contacts_edit_page ||= PageObjects::Page::Organisations::UcasContactsEdit.new
  end

  def recruitment_cycle
    @recruitment_cycle ||= build(:recruitment_cycle)
  end

  def stub_initial_provider_request
    stub_api_v2_resource(provider, include: "contacts")
  end

  def stub_updated_provider_request
    provider.contacts = []
    updated_contacts.each { |contact| provider.contacts << contact }

    stub_api_v2_resource(provider, include: "contacts")
  end

  def stub_update_request
    stub_api_v2_request("/contacts/#{admin_contact.id}", admin_contact, :patch)
  end

  def stub_invalid_update_request
    stub_api_v2_request("/contacts/#{admin_contact.id}", build(:error), :patch, 422)
  end
end
