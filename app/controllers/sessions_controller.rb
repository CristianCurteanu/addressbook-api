class SessionsController < ApplicationController
  before_action only: :create do
    error! 400, error: 'Parameters are not valid' unless valid_credentials?
  end

  api :POST, '/session', 'Create a new session token'
  header :Cookie, 'Provide `uuid` key as cookie', required: true
  param :email, String, desc: 'User`s email', required: true
  param :password, String, desc: 'User`s password', required: true
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
