class UserType < ApplicationRecord
  # belongs_to :user
  has_many :user, foreign_key: 'user_type_id'
end
