module Providers
  class AccessRequestsController < ApplicationController
    def index
      @access_requests = AccessRequest
                           .includes(:requester)
                           .all
    end

    def new_manual
      @access_request = AccessRequest.new
    end

    def new
      @access_request = AccessRequest.new
    end

    def approve
      new_access_request = AccessRequest.new(id: params[:id])
      new_access_request.approve
      flash[:success] = "Successfully approved request"
      redirect_to access_requests_path
    end

    def confirm
      @access_request = AccessRequest.includes(:requester).find(params[:id]).first
    end

    def create
      @access_request = AccessRequest.new(access_request_params)

      if params[:code]
        if @access_request.save
          redirect_to provider_path(params[:code]),
                      flash: { success: "Your request for access has been submitted" }
        else
          @errors = @access_request.errors.messages

          render :new
        end
      else
        if @access_request.save
          redirect_to confirm_access_request_path(@access_request.id)
        else
          @errors = @access_request.errors.messages

          render :new_manual
        end
      end
    end

  private

    def access_request_params
      params.require(:access_request).permit(
        :first_name,
        :last_name,
        :email_address,
        :organisation,
        :reason,
        :requester_email,
      ).to_h
    end
  end
end
