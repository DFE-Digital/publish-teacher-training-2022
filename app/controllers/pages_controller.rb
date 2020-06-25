class PagesController < ApplicationController
  skip_before_action :request_login, only: %i[guidance accessibility terms cookies privacy performance_dashboard]

  def accessibility; end

  def cookies; end

  def terms; end

  def privacy; end

  def guidance; end

  def accredited_body_new_features; end

  def transition_info; end

  def rollover; end

  def rollover_recruitment; end

  def accept_terms; end

  def performance_dashboard; end
end
