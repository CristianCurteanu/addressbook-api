class User < ApplicationRecord
  has_and_belongs_to_many :organizations
  belongs_to :type, class_name: 'UserType', foreign_key: 'user_type_id'

  validates_presence_of :email
  validates_format_of :email, 
                      :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  validates :email, uniqueness: { case_sensitive: false }
end
