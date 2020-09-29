class Contact < Base
  belongs_to :provider, param: :provider_code, shallow_path: true

  def admin?
    type == "admin"
  end
end
