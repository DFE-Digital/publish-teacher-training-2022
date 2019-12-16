module PageObjects
  module Page
    class OrganisationsPage < PageObjects::Base
      set_url "/organisations-support-page"

      sections :organisations, '[data-qa="organisations-table-row"]' do
        element :name, '[data-qa="organisation-table-row__name"]'
        element :users, '[data-qa="organisation-table-row__users"]'
        element :providers, '[data-qa="organisation-table-row__providers"]'
      end
    end
  end
end
