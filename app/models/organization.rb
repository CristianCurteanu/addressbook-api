class Organization < ApplicationRecord
  has_and_belongs_to_many :users
  validates_presence_of :name
  validates_uniqueness_of :name

  def contacts
    Contact.new(organization: self)
  rescue Errno::ECONNRESET
    nil
  end
end
