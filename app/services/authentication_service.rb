class AuthenticationService
  prepend SimpleCommand

  def initialize(options = {})
    @email = options[:email]
    @password = options[:password]
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
