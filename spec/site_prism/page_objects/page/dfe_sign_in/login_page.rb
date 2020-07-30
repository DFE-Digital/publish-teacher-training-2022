module PageObjects
  module Page
    module DFESignIn
      class LoginPage < PageObjects::Base
        set_url "https://test-interactions.signin.education.gov.uk//{session_id}/usernamepassword?clientid={client_id}&redirect_uri={redirect_url}"
        set_url_matcher(%r{https://\w+-interactions.signin.education.gov.uk/+[a-z0-9-]+/usernamepassword\?clientid=.*?&redirect_uri=.*?})

        element :username, "input#username"
        element :password, "input#password"
        element :sign_in, "div.submit-buttons button"
      end
    end
  end
end
