class ProvidersView
  def initialize(providers:)
    @providers = providers
  end

  def show_notifications_link?
    accredited_body_count > 1
  end

private

  def accredited_body_count
    providers.select(&:accredited_body?).count
  end

  attr_reader :providers
end
