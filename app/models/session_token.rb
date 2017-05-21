class SessionToken < ApplicationRecord

  def logout
    self.update!(expires_at: DateTime.now - 1.minute)
  end

  def self.expired?(token)
    DateTime.now > SessionToken.find_by_token(token).expires_at
  rescue NoMethodError
    nil
  end
end