class AuthorizationService
  prepend SimpleCommand

  def initialize(headers = {})
    @headers = headers
  end

  def call
    User.find(authorization_token[:user_id]) if authorization_token
  end

  private

  attr_accessor :headers

  def authorization_token
    @authorization_token = WebTokenHelper.decode(authorization_header)
  end

  def authorization_header
    headers['Authorization'].split(' ').last if headers['Authorization'].present?
  end
end
