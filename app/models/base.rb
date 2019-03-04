class Base < JsonApiClient::Resource
  self.site = "#{Settings.manage_backend.base_url}/api/v2/"
end
