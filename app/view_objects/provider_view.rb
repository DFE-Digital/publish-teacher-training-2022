class ProviderView
  def initialize(provider:, providers:)
    @provider = provider
    @providers = providers
  end

  def show_notifications_link?
    accredited_body? && accredited_body_count == 1
  end

private

  def accredited_body_count
    providers.select(&:accredited_body?).count
  end

  def accredited_body?
    provider.accredited_body?
  end

  attr_reader :provider, :providers
end
