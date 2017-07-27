require 'rails_helper'

describe 'Organizations' do
  before(:each) do
    @organization ||= Organization.create!(name: Faker::Company.name)
    3.times do
      @organization.users << User.create!(email: Faker::Internet.email,
                                          password: Faker::Internet.password,
                                          type: UserType.create!(name: 'USER'))
    end
    @organization_users ||= @organization.users.as_json.each_with_object([]) do |h, array|
      array << h.slice('id', 'email')
    end.to_json
    uuid = SecureRandom.uuid
    email = Faker::Internet.email
    @client = Client.create!(email: email,
                             uuid:  uuid,
                             key: JWT.encode(email, uuid))
  end

  context 'GET /organizations' do
    it 'get a list of organization' do
      stub_request(:get, organization_by_id(@organization.id))
        .to_return(body: {}.to_json)
      get '/organizations', headers: { Authorization: token_for(:user),
                                       Accept: 'application/json' }
      expect_status 200
      target = [@organization.slice(:id, :name).merge(contacts: @organization.contacts.get)]
      expect(response.body).to eql target.to_json
    end

    it 'should return 404 response if no company found' do
      @organizations = Organization.delete_all
      get '/organizations', headers: { Authorization: token_for(:user),
                                       Accept: 'application/json' }
      expect_status 404
      expect_json error: 'No organization found'
    end
  end

  context 'GET /organization/:id' do
    it 'should return 404 if company not found by id' do
      id = @organization.id + 1
      get "/organization/#{id}", headers: { Authorization: token_for(:user),
                                            Accept: 'application/json' }
      expect_status 404
      expect_json message: "Couldn't find Organization with 'id'=#{id}"
    end

    it 'should return organization data' do
      stub_request(:get, organization_by_id(@organization.id))
        .to_return(body: {}.to_json)
      organization = @organization.slice(:id, :name)
                                  .merge(contacts: @organization.contacts.get)
      get "/organization/#{@organization.id}", headers: {
                                                Authorization: token_for(:user),
                                                Accept: 'application/json'
                                              }
      expect_status 200
      expect(response.body).to eql organization.to_json
    end
  end

  context 'POST /organization' do
    it 'returns 401 if user is not Admin' do
      post '/organization', params:  { name: Faker::Company.name },
                            headers: { Authorization: token_for(:user),
                                       Accept: 'application/json' }
      expect_status 401
    end

    it 'should add new organization and return 200' do
      post '/organization', params:  { name: Faker::Company.name },
                            headers: { Authorization: token_for(:admin),
                                       Accept: 'application/json' }
      expect_status 200
      expect(response.body).to eql({ message: 'OK' }.to_json)
    end

    it 'should return 400 if `name` parameter is not sent' do
      post '/organization', params:  {},
                            headers: { Authorization: token_for(:admin),
                                       Accept: 'application/json' }
      expect_status 422
    end
  end

  context 'POST /organization/contact' do
    it 'should be able to add new contact if client is User' do
      stub_request(:get, organization_by_id(@organization.id))
        .to_return(body: [].to_json)
      mock_data = { key: Faker::Company.name }
      stub_request(:put, organization_by_id(@organization.id))
        .to_return(body: [mock_data].to_json)
      post '/organization/contact', params:  { organization_id: @organization.id,
                                               data:            mock_data.to_json },
                                    headers: { Authorization: token_for(:user),
                                               Accept: 'application/json' }
      expect_status 200
      expect(response.body).to eql({ message: 'OK' }.to_json)
    end

    it 'should return 401 if client is not logged in' do
      mock_data = { key: Faker::Company.name }
      post '/organization/contact', params:  { organization_id: @organization.id,
                                               data:            mock_data.to_json },
                                    headers: { Authorization: nil,
                                               Accept: 'application/json' }
      expect_status 401
    end

    it 'should return 400 if organization_id is not present' do
      mock_data = { key: Faker::Company.name }
      post '/organization/contact', params:  { data: mock_data.to_json },
                                    headers: { Authorization: token_for(:user),
                                               Accept: 'application/json' }
      expect_status 400
    end

    it 'should return 400 if data is not present' do
      post '/organization/contact', params:  { organization_id: @organization.id },
                                    headers: { Authorization:  token_for(:user),
                                               Accept: 'application/json' }
      expect_status 400
    end
  end

  context 'PUT /organization/:id/:field' do
    it 'should update organization name by id only if logged in' do
      id = @organization.id
      new_name = Faker::Company.name
      put "/organization/#{id}/name", params:  { value: new_name },
                                      headers: { Authorization: token_for(:user),
                                                 Accept: 'application/json' }
      expect_status 200
      expect(response.body).to eql({ message: 'OK' }.to_json)
    end

    it 'should update organization description by id only if logged in' do
      id = @organization.id
      description = Faker::Company.catch_phrase
      put "/organization/#{id}/name", params:  { value: description },
                                      headers: { Authorization: token_for(:user),
                                                 Accept: 'application/json' }
      expect_status 200
      expect(response.body).to eql({ message: 'OK' }.to_json)
    end

    it 'should return 401 if not logged in' do
      id = @organization.id
      new_name = Faker::Company.name
      put "/organization/#{id}/name", params: { value: new_name },
                                      headers: { Accept: 'application/json' }
      expect_status 401
    end
  end

  context 'PUT /organization/contacts' do
    def updated(contacts)
      id = @organization.id
      updatable = new_contact.values.first
      key = contacts.first.keys[0]
      contacts.first[key] = updatable
      OpenStruct.new(id: id, key: key, value: updatable, contacts: contacts)
    end

    it 'should be able to update contacts if logged in' do
      contacts = []
      3.times { contacts << new_contact }
      r = updated(contacts)
      stub_request(:get, organization_by_id(r.id)).to_return(body: contacts.to_json)
      stub_request(:put, organization_by_id(r.id)).to_return(body: r.contacts.to_json)
      put '/organization/contact', params:  { id: r.id,
                                               key: r.key,
                                               data: r.value.to_json },
                                    headers: { Authorization: token_for(:user),
                                               Accept: 'application/json' }
      expect_status 200
      expect(response.body).to eql({ message: 'OK' }.to_json)
    end

    it 'should return 401 unless logged in' do
      id = @organization.id
      stub_request(:get, organization_by_id(id)).to_return(body: {}.to_json)
      put '/organization/contact', params:  { id: id,
                                               key: SecureRandom.uuid,
                                               data: {}.to_json },
                                   headers: { Accept: 'application/json' }
      expect_status 401
    end

    it 'should return 404 if company not found' do
      contacts = []
      3.times { contacts << new_contact }
      r = updated(contacts)
      stub_request(:get, organization_by_id(r.id)).to_return(body: contacts.to_json)
      put '/organization/contact', params:  { id: r.id + 1,
                                               key: r.key,
                                               data: r.value.to_json },
                                    headers: { Authorization: token_for(:user),
                                               Accept: 'application/json' }
      expect_status 404
      expect(response.body).to eql({ message: "Couldn't find Organization with 'id'=#{r.id + 1}" }.to_json)
    end
  end

  context 'DELETE /organization/:id' do
    it 'should delete organization only if logged in as admin' do
      id = @organization.id
      stub_request(:put, organization_by_id(id)).to_return(body: [].to_json)
      delete "/organization/#{id}", headers: { Authorization: token_for(:admin),
                                               Accept: 'application/json' }
      expect_status 200
      get "/organization/#{id}", headers: { Authorization: token_for(:user),
                                            Accept: 'application/json' }
      expect_status 404
    end

    it 'should return 401 unless admin' do
      id = @organization.id
      delete "/organization/#{id}", headers: { Accept: 'application/json' }
      expect_status 401
    end

    it 'should return 404 if company not found' do
      id = @organization.id
      stub_request(:put, organization_by_id(id)).to_return(body: [].to_json)
      delete "/organization/#{id + 1}", headers: { Authorization: token_for(:admin),
                                                   Accept: 'application/json' }
      expect_status 404
    end
  end
end
