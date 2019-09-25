class ErrorsController < ApplicationController
  skip_before_action :verify_authenticity_token,
                     :authenticate

  def not_found
    respond_to do |format|
      format.html { render status: :not_found }
      format.json { render json: { error: "Resource not found" }, status: :not_found }
      format.all { render status: :not_found, body: nil }
    end
  end

  def internal_server_error
    respond_to do |format|
      format.html { render status: :internal_server_error }
      format.json { render json: { error: "Internal server error" }, status: :internal_server_error }
    end
  end

  def forbidden
    respond_to do |format|
      format.html { render status: :forbidden }
      format.json { render json: { error: "Forbidden" }, status: :forbidden }
    end
  end

  def unauthorized
    respond_to do |format|
      format.html { render status: :unauthorized }
      format.json { render json: { error: "Unauthorized" }, status: :unauthorized }
    end
  end
end
