module OrganisationHelper
  def user_details(user, dfe_signin_deeplink: false)
    if dfe_signin_deeplink && user.sign_in_user_id.present?
      link_to "#{user.first_name} #{user.last_name} <#{user.email}>",
              "#{Settings.dfe_signin.user_search_url}/#{user.sign_in_user_id}/audit",
              class: "govuk-link"
    else
      "#{user[:first_name]} #{user[:last_name]} <#{user[:email]}>"
    end
  end

  def provider_details(provider)
    link_to "#{provider.provider_name} [#{provider.provider_code}]",
            provider_path(provider.provider_code), class: "govuk-link"
  end
end
