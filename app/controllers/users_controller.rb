class UsersController < ApplicationController
  def accept_terms
    @user = User.find(params[:id]).first
  end
end
