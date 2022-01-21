class ProvidersController < ApplicationController
  decorates_assigned :provider
  decorates_assigned :training_provider
  before_action :build_recruitment_cycle
  rescue_from JsonApiClient::Errors::NotFound, with: :not_found
  before_action :build_provider, except: %i[index show]
  before_action :build_training_provider, only: %i[training_provider_courses]

  def index
    page = (params[:page] || 1).to_i
    per_page = 10

    @providers = providers.page(page)

    @pagy = Pagy.new(count: @providers.meta.count, page: page, items: per_page)

    render "providers/no_providers", status: :forbidden if @providers.empty?
    redirect_to provider_path(@providers.first.provider_code) if @providers.size == 1
  end

  def show
    @provider = Provider
      .where(recruitment_cycle_year: @recruitment_cycle.year)
      .find(params[:code])
      .first
  end

  def details
    redirect_to_new_publish_url_details_provider_recruitment_cycle_path if FeatureService.enabled?("new_publish.about_your_org")

    redirect_to_contact_page_with_ukprn_error if @provider.ukprn.blank?

    @errors = flash[:error_summary]
    flash.delete(:error_summary)
  end

  def contact
    redirect_to_new_publish_url_contact_provider_recruitment_cycle_path if FeatureService.enabled?("new_publish.about_your_org")

    show_deep_linked_errors(%i[email telephone website address1 address3 address4 postcode])
  end

  def about
    redirect_to_new_publish_url_about_provider_recruitment_cycle_path if FeatureService.enabled?("new_publish.about_your_org")

    show_deep_linked_errors(%i[train_with_us train_with_disability])
  end

  def update
    if @provider.update(provider_params)
      flash[:success] = I18n.t("success.published")
      redirect_to(
        details_provider_recruitment_cycle_path(
          @provider.provider_code,
          @provider.recruitment_cycle_year,
        ),
      )
    else
      @errors = @provider.errors.messages

      render provider_params["page"].to_sym
    end
  end

  def publish
    if @provider.publish
      flash[:success] = I18n.t("success.published")
    else
      flash[:error_summary] = @provider.errors.messages
    end

    redirect_to details_provider_recruitment_cycle_path(@provider.provider_code, @recruitment_cycle.year)
  end

  def training_providers
    @training_providers = TrainingProvider.where(recruitment_cycle_year: @recruitment_cycle.year, provider_code: @provider.provider_code)
    @training_providers.delete_if { |tp| tp.provider_code == @provider.provider_code }
    @course_counts = @training_providers.meta[:accredited_courses_counts]
  end

  def training_provider_courses
    @courses = Course
      .where(recruitment_cycle_year: @recruitment_cycle.year)
      .where(provider_code: @training_provider.provider_code)
      .where(accredited_body_code: @provider.provider_code)
      .map(&:decorate)

    @courses.sort_by!(&:name)
  end

  def search
    provider_query = params[:query]

    if provider_query.blank?
      flash[:error] = { id: "provider-error", message: "Name or provider code" }
      return redirect_to organisations_path
    end

    provider_code = provider_query
                      .split(" ")
                      .last
                      .gsub(/[()]/, "")

    redirect_to provider_path(provider_code)
  end

private

  def provider_params
    permitted_params = params.require(:provider).permit(
      :page,
      :train_with_us,
      :train_with_disability,
      :email,
      :telephone,
      :urn,
      :website,
      :ukprn,
      :address1,
      :address2,
      :address3,
      :address4,
      :postcode,
      :region_code,
      accredited_bodies_attributes: %i[provider_name provider_code description],
    ).to_h # Without this, accredited_bodies is an array of params objects
    # instead of an array of plain hashes and gets serialized incorrectly
    # on its way to the backend.
    permitted_params.merge(accredited_bodies_param).except(:accredited_bodies_attributes)
  end

  def accredited_bodies_param
    ab = params.require(:provider).except(
      :page,
      :train_with_us,
      :train_with_disability,
      :email,
      :telephone,
      :urn,
      :website,
      :ukprn,
      :address1,
      :address2,
      :address3,
      :address4,
      :postcode,
      :region_code,
    )
      .permit(accredited_bodies_attributes: %i[provider_name provider_code description])
    { accredited_bodies: ab[:accredited_bodies_attributes].to_h.values }
  end

  def build_provider
    @provider = Provider
      .where(recruitment_cycle_year: @recruitment_cycle.year)
      .find(params[:provider_code])
      .first
  end

  def build_training_provider
    @training_provider = TrainingProvider
      .where(recruitment_cycle_year: @recruitment_cycle.year, provider_code: @provider.provider_code)
      .find(params[:training_provider_code])
      .first
  end

  def show_deep_linked_errors(attributes)
    return if params[:display_errors].blank?

    @provider.publishable?
    @errors = @provider.errors.messages.select { |key| attributes.include? key }
  end

  def build_recruitment_cycle
    # this is due to #training_provider_courses being nested as a route
    # this causes the route param "year" to be prefixed
    cycle_year = params[:recruitment_cycle_year] || params[:year] || Settings.current_cycle

    @recruitment_cycle = RecruitmentCycle.find(cycle_year).first
  end

  def providers
    @providers ||= Provider.where(recruitment_cycle_year: Settings.current_cycle)
  end

  def redirect_to_new_publish_url_about_provider_recruitment_cycle_path
    redirect_to new_publish_url(about_provider_recruitment_cycle_path(@provider.provider_code, @provider.recruitment_cycle_year))
  end

  def redirect_to_new_publish_url_contact_provider_recruitment_cycle_path
    redirect_to new_publish_url(contact_provider_recruitment_cycle_path(@provider.provider_code, @provider.recruitment_cycle_year))
  end

  def redirect_to_new_publish_url_details_provider_recruitment_cycle_path
    redirect_to new_publish_url(details_provider_recruitment_cycle_path(@provider.provider_code, @provider.recruitment_cycle_year))
  end

  def redirect_to_new_publish_url_show_provider_recruitment_cycle_path
    redirect_to new_publish_url(provider_recruitment_cycle_path(@provider.provider_code, @provider.recruitment_cycle_year))
  end

  def redirect_to_contact_page_with_ukprn_error
    flash[:error] = { id: "provider-error", message: "Please enter a UKPRN before continuing" }

    redirect_to contact_provider_recruitment_cycle_path(@provider.provider_code, @provider.recruitment_cycle_year)
  end
end
