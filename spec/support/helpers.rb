module Helpers
  def stub_omniauth(user: nil)
    user ||= build(:user)

    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:dfe] = {
      'provider' => 'dfe',
      'uid'      => SecureRandom.uuid,
      'info'     => {
        'first_name' => user.first_name,
        'last_name'  => user.last_name,
        'email'      => user.email,
        'id'         => user.id,
        'state'      => user.state
      },
      'credentials' => {
        'token_id' => '123'
      }
    }

    # This is needed because we check the provider count on all pages
    # TODO: Move this to be returned with the user.
    stub_api_v2_request(
      "/recruitment_cycles/#{Settings.current_cycle}/providers",
      build(:provider).to_jsonapi
    )
    Rails.application.env_config['omniauth.auth'] = OmniAuth.config.mock_auth[:dfe]
    stub_api_v2_request('/sessions', user.to_jsonapi, :post)
  end

  def stub_api_v2_request(url_path, stub, method = :get, status = 200, token: nil)
    url = "#{Settings.manage_backend.base_url}/api/v2#{url_path}"

    stubbed_request = stub_request(method, url)
                        .to_return(
                          status: status,
                          body: stub.to_json,
                          headers: { 'Content-Type': 'application/vnd.api+json' }
                        )
    if token
      stubbed_request.with(
        headers: {
          'Accept'          => 'application/vnd.api+json',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Authorization'   => "Bearer #{token}",
          'Content-Type'    => 'application/vnd.api+json',
          'User-Agent'      => 'Faraday v0.15.4'
        }
      )
    end

    stubbed_request
  end

  def stub_api_v2_resource(resource,
                           jsonapi_response: nil,
                           include: nil)
    query_params = {}
    query_params[:include] = include if include.present?

    url = url_for_resource(resource)
    url += "?#{query_params.to_param}" if query_params.any?

    jsonapi_response ||= resource.to_jsonapi(include: include)
    stub_api_v2_request(url, jsonapi_response)
  end

  def stub_api_v2_new_resource(resource, jsonapi_response = nil)
    url = url_for_new_resource(resource)

    jsonapi_response ||= resource.to_jsonapi
    stub_api_v2_request(url, jsonapi_response)
  end

  def stub_api_v2_resource_collection(resources, jsonapi_response: nil)
    url = url_for_resource_collection(resources.first)

    jsonapi_response ||= resource_list_to_jsonapi(resources)
    stub_api_v2_request(url, jsonapi_response)
  end

  def stub_api_v2_empty_resource_collection(resource,
                                            child_resource,
                                            jsonapi_response: nil)
    url = url_for_resource(resource) + "/#{child_resource}"

    jsonapi_response ||= resource_list_to_jsonapi([])
    stub_api_v2_request(url, jsonapi_response)
  end

private

  def url_for_resource(resource)
    base_url = url_for_resource_collection(resource)

    if resource.is_a?(RecruitmentCycle)
      "#{base_url}/#{resource.year}"
    elsif resource.is_a?(Provider)
      "#{base_url}/#{resource.provider_code}"
    elsif resource.is_a?(Course)
      "#{base_url}/#{resource.course_code}"
    end
  end

  def url_for_resource_collection(resource)
    if resource.is_a? RecruitmentCycle
      '/recruitment_cycles'
    elsif resource.is_a? Provider
      url_for_resource(resource.recruitment_cycle) + '/providers'
    elsif resource.is_a? Course
      url_for_resource(resource.provider) + '/courses'
    end
  end

  def url_for_new_resource(resource)
    base_url = url_for_resource_collection(resource)
    "#{base_url}/new"
  end
end

RSpec.configure do |config|
  config.include Helpers, type: :feature
  config.include Helpers, type: :controller
  config.include Helpers, type: :request
end
