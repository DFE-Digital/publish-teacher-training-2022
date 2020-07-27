class PagesController < ApplicationController
  skip_before_action :check_interrupt_redirects

  skip_before_action :request_login, only: %i[guidance accessibility terms cookies privacy performance_dashboard]

  def accessibility; end

  def cookies; end

  def terms; end

  def privacy; end

  def guidance; end

  def new_features; end

  def notifications_info; end

  def transition_info; end

  def rollover; end

  def rollover_recruitment; end

  def accept_terms; end

  def performance_dashboard
    @performance_data = PerformanceDashboardService.call
  end
end
