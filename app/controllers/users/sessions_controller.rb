class Users::SessionsController < Devise::SessionsController
  respond_to :json, :html

  def create
    self.resource = warden.authenticate!(auth_options)
    sign_in(resource_name, resource)
    respond_to do |format|
      format.json { render json: { message: 'Signed in successfully', user: resource }, status: :ok }
      format.html { super }
    end
  end

  def respond_to_on_destroy
    if current_user
      render json: { message: "Signed out successfully" }, status: :ok
    else
      render json: { error: "User has no active session" }, status: :unauthorized
    end
  end
end
