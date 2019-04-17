class UsersController < ApplicationController
  before_action :authenticate, :build_user

  def accept_terms; end

  def update
    if @user.update(user_params)
      redirect_to providers_path
    else
      @errors = @user.errors.reduce({}) { |errors, (field, message)|
        errors[field] ||= []
        errors[field].push(map_errors(message))
        errors
      }
      render :accept_terms
    end
  end

private

  def build_user
    @user = User.find(params[:id]).first
  end
end
