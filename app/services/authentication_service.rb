class AuthenticationService
  prepend SimpleCommand

  def initialize(options = {})
    @email = options[:email]
    @password = options[:password]
  end

  def call
    return WebTokenHelper.encode(user_id: user.id) if user
  end

  def self.destroy(token)
    WebTokenHelper.encode({ user_id: WebTokenHelper.decode(token) }, 1.minute.ago)
  end

  private

  attr_accessor :email, :password

  def user
    user = User.find_by_email(email)
    return user if user && user.authenticate(password)
  end
end
