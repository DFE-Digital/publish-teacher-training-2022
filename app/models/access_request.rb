class AccessRequest < Base
  custom_endpoint :approve, on: :member, request_method: :post

  def recipient
    User.new(first_name: first_name, last_name: last_name, email: email_address)
  end
end
