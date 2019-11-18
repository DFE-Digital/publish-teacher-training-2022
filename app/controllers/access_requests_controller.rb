class AccessRequestsController < ApplicationController
  def index
    @access_requests = AccessRequest
                         .includes(:requester)
                         .all
  end

  def new
    @access_request = AccessRequest.new
  end

  def approve
    new_access_request = AccessRequest.new(id: params[:id])
    new_access_request.approve
    flash[:success] = "Successfully approved request"
    redirect_to inform_publisher_access_request_path
  end

  def inform_publisher
    @access_request = AccessRequest.includes(:requester, requester: [:organisations]).find(params[:id]).first
  end

  def confirm
    @access_request = AccessRequest.includes(:requester, requester: [:organisations]).find(params[:id]).first
  end

  def create
    @access_request = AccessRequest.new(access_request_params)

    if @access_request.save
      redirect_to confirm_access_request_path(@access_request.id)
    else
      @errors = @access_request.errors.messages

      render :new
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
