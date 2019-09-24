class ProviderDecorator < ApplicationDecorator
  delegate_all

  def accredited_bodies
    object.accredited_bodies.sort_by { |provider| provider["provider_name"] }
  end
end
