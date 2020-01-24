class PagesController < ApplicationController
  skip_before_action :request_login, only: %i[guidance accessibility terms cookies privacy new_features]

  def accessibility; end

  def cookies; end

  def terms; end

  def privacy; end

  def guidance; end

  def new_features; end

  def transition_info; end

  def rollover; end

  def accept_terms; end
end
