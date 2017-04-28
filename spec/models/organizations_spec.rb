require 'rails_helper'

describe Organization, type: :model do
  
  it 'should have and belong to many users' do 
    should have_and_belong_to_many(:users)
  end

  it 'should be valid with name' do 
    expect(Organization.new).not_to be_valid
    expect(Organization.new(name: 'Sample Organization Inc.')).to be_valid
  end

  it 'should be able to add users' do 
    organization = Organization.new(name: 'Sample Organization Inc.')
    organization.users << User.new(email: 'some.email@gmail.com')
    expect(organization.users).to be_present
  end
end