require 'rails_helper'

describe AddressBook::OrganizationResource do 
  before(:each) do 
    @organization ||= Organization.create!(name: Faker::Company.name,
                                           city: City.create!(name: Faker::Address.city,
                                                              country: Country.create!(name: Faker::Address.country))
                                          )
    3.times do
      @organization.users << User.create!(email: Faker::Internet.email,
                                           password: Faker::Internet.password,
                                           type: UserType.create!(name: 'USER')
                                          )
    end
    @organization_users ||= @organization.users.as_json.each_with_object([]) do |h, array|
                              array << h.slice('id', 'email')
                            end.to_json
    @contacts = Contacts.add(name: Faker::Internet)                            
  end 

  context 'GET /organizations' do
    it 'get a list of organization' do 
      organizations = [{ id: @organization.id, 
                      name: @organization.name, 
                      city: @organization.city.name,
                      country: @organization.city.country.name }].to_json
      get '/organizations'
      expect(response.body).to eql organizations                      
    end 

    it 'should return 404 response if no company found' do 
      Organization.delete_all
      get '/organizations'
      expect_status 404
      expect_json message: 'No company found'
    end
  end

  context 'GET /organization/:id|:name' do 
    it 'should return 404 if company not found by id' do 
      get "/organization/#{@organization.id + 1}"
      expect_status 404
      expect_json error: 'Company not found'
    end

    it 'should return 404 if company not found by name' do 
      get "/organization/#{@organization.name}_test"
      expect_status 404
      expect_json error: 'Company not found'
    end

    it 'should return organization data' do
      stub_request(:get, "http://example.firebase.com/organization/#{@organization.id}")
      binding.pry
      get "/organization/#{@organization.id}"
      expect_status 200
      # organization = { id: @organization.id, name: }
    end
  end

  context 'POST /organization'

  context 'PUT /organization/:id'
end