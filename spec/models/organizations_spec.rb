require 'rails_helper'

describe Organization, type: :model do
  it 'should have and belong to many users' do
    should have_and_belong_to_many(:users)
  end

  it 'should be valid with name' do
    expect(described_class.new).not_to be_valid
    expect(described_class.new(name: 'Sample Organization Inc.')).to be_valid
  end

  it 'should be able to add users' do
    organization = described_class.new(name: 'Sample Organization Inc.')
    organization.users << User.new(email: 'some.email@gmail.com')
    expect(organization.users).to be_present
  end

  it 'should serialize with contacts' do
    organization = described_class.new(name: 'Sample Organization Inc.')
    stub_request(:get, organization_by_id(organization.id))
      .to_return(body: {}.to_json)
    expect(organization.contacts.get.to_json).to eql([].to_json)
  end
end
