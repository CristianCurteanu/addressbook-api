require 'rails_helper'

describe Contact do
  before(:each) do
    @contact ||= [new_contact]
    @organization ||= Organization.create(name: Faker::Company.name)   
    stub_request(:get, organization_by_id(@organization.id)).
      to_return(body: @contact.to_json)         
  end

  # Contact.get(12) => Return all contacts for organization with id=12
  it 'should get a list of contacts for specific organization' do
    contacts = @organization.contacts.get
    expect(contacts.to_json).to eql @contact.to_json
  end

  # organization.contacts.add({key: value})
  it 'should add new contact data for existing organization' do
    contact = new_contact
    @contact.push(contact)
    stub_request(:put, organization_by_id(@organization.id)).
      to_return(body: @contact.to_json)
    response = @organization.contacts.add(contact)
    expect(response.body.to_json).to eql @contact.to_json
  end

  # organization.contacts.update key, data
  it 'should update existing contact data for specific organization' do
    key, data = @contact[0].keys[0], new_contact.values[0]
    @contact = @contact.first[key] = data
    stub_request(:put, organization_by_id(@organization.id)).
      to_return(body: @contact.to_json, status: 200)
    response = @organization.contacts.update(key, data)
    expect(response.body.to_json).to eql @contact.to_json
  end

  def organization_by_id(id)
    "https://example.firebase.com/organization/#{id}.json"
  end

  def new_contact
    {SecureRandom.uuid => { value: Faker::Internet.email }}
  end
end

# organization.contacts