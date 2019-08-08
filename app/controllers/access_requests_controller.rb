class AccessRequestsController < ApplicationController
  def new
    @access_request = AccessRequest.new
  end

  def create
    @access_request = AccessRequest.new(access_request_params)

    if @access_request.save
      redirect_to provider_path(params[:code]),
                  flash: { success: 'Your request for access has been submitted' }
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
      :reason
    ).to_h
  end
end
