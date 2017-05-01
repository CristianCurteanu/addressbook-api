require 'rails_helper'

describe Contact do
  before(:each) do
    @datas ||= new_contact
    @organization ||= Organization.create(name: Faker::Company.name)            
    @contact_data ||= Contact.new(@datas.merge(organization: @organization))
    
  end

  # Contact.get(12) => Return all contacts for organization with id=12
  it 'should get a list of contacts for specific organization' do
    stub_request(:get, "https://example.firebase.com/organization/#{@organization.id}.json").
      to_return(body: @datas.to_json)
    contacts = @contact_data.get
    expect(contacts.to_json).to eql @datas.to_json
  end

  # Contact.new().save
  it 'should add new contact data for existing organization' do 

    expect_status
  end

  # Contact.update id, { name: String, avatar_url: String, contacts: Hash }
  it 'should update existing contact data for specific organization'

  # Contact.where(id: Integer).delete
  it 'should be able to remove contact data'
  
  # Contact.name => String
  it 'should have name' do
    expect(@contact_data.name).not_to eql nil
    expect(@contact_data.name).to eql @datas[:name]
  end

  # Contact.address => Hash 
  it 'should have address' do 
    expect(@contact_data.address).to eql @datas[:address]
  end

  def new_contact
    { name: Faker::Company.name,
      address: {
        type:  'EMAIL',
        value: Faker::Internet.email
      },
      contacts: [{ 
        city: Faker::Address.city, 
        country: Faker::Address.country, 
        details: Faker::Address.street_address 
      }]
    }
  end
end

# organization.contacts