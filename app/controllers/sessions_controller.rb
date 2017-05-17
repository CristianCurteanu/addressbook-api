class SessionsController < ApplicationController
  before_action only: :create do
    error! 400, error: 'Parameters are not valid' unless valid_credentials?
  end

  def create
    authentication ||= AuthenticationService.call(credentials)
    if authentication && authentication.success?
      render json: { token: authentication.result }
    else
      error! 401, error: 'Authentication failed, check you credentials'
    end
  end

  def destroy
    AuthenticationService.destroy(request.headers['Authorization'])
  end

  private

  def authentication_params
    params.permit(:email, :password)
  end

  def valid_credentials?
    [:email, :password].all? { |key| authentication_params.key? key }
  end
end
