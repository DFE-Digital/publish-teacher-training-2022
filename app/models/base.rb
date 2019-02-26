class Base < JsonApiClient::Resource
  self.site = "#{ENV['MANAGE_BACKEND_BASE_URL']}/api/v2/"
end
