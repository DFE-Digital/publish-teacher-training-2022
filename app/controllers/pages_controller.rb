class PagesController < ApplicationController
  skip_before_action :request_login, only: %i[guidance accessibility terms cookies privacy performance_dashboard]

  before_action :skip_already_transitioned_interruptions,
                only: %i[transition_info rollover notifications_info]

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

private

  def skip_already_transitioned_interruptions
    user = User.find(current_user["user_id"]).first
    if user_state_to_redirect_paths[user.next_state] != request.fullpath
      redirect_to_correct_page(user, use_redirect_back_to: false)
    end
  end
end
