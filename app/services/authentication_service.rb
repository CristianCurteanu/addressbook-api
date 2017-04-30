class AuthenticationService
  prepend SimpleCommand

  def initialize(email, password)
    @email = email
    @password = password
  end

  def call
    WebTokenHelper.encode(user_id: user.id) if user
  end

  private

  attr_accessor :email, :password

  def user
    user = User.find_by_email(email)
    return user if user && user.authenticate(password)
  end
end
