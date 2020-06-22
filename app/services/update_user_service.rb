class UpdateUserService
  def self.call(user, method)
    new(user, method).update_user
  end

  def initialize(user, method)
    @user = user
    @method = method
  end

  def update_user
    @user.__send__(@method)
  rescue JsonApiClient::Errors::ClientError, JsonApiClient::Errors::ServerError => e
    e.env.body.delete("traces")
    Raven.extra_context(e.env)

    if e.is_a? JsonApiClient::Errors::ClientError
      Raven.capture_exception(e)
    else
      raise e
    end
  end
end
