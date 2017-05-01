class Organization < ApplicationRecord
  has_and_belongs_to_many :users
  validates_presence_of :name
  serialize :contacts, OpenStruct
end
