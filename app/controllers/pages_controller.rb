class PagesController < ApplicationController
  before_action :authenticate, except: :guidance

  def cookies; end

  def terms; end

  def privacy; end

  def guidance; end

  def transition; end
end
