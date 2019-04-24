class ErrorsController < ApplicationController
  skip_before_action :verify_authenticity_token,
                    only: %i[not_found internal_server_error forbidden unauthorised]
  skip_before_action :authenticate

  def not_found
    respond_to do |format|
      format.html { render status: :not_found }
      format.json { render json: { error: 'Resource not found' }, status: :not_found }
      format.all { render status: :not_found, body: nil }
    end
  end

  def internal_server_error
    respond_to do |format|
      format.html { render status: :internal_server_error }
      format.json { render json: { error: 'Internal server error' }, status: :internal_server_error }
    end
  end

  def forbidden
    respond_to do |format|
      format.html { render status: :forbidden }
      format.json { render json: { error: 'Forbidden' }, status: :forbidden }
    end
  end
end
