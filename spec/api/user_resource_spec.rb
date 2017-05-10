require 'rails_helper'

describe AddressBook::UsersResource do
  before(:all) do
    @user ||= User.create!(email: 'some.email@gmail.com',
                           type: UserType.create!(name: 'USER'),
                           password: 'some.password')
    @user.organizations << Organization.create!(name: 'Some Organization Inc.')
    @user.organizations << Organization.create!(name: 'Second Organization Inc.')
    uuid = SecureRandom.uuid
    @client = Client.create!(email: @user.email, 
                             uuid:  uuid, 
                             key: JWT.encode(@user.email, uuid))
  end

  let(:user_organizations) do
    @user.organizations.as_json.each_with_object([]) do |h, array|
      array << h.slice('id', 'name')
    end
  end

  context 'GET /user/:id' do
    it 'should return a user by id' do
      user_json = { email: @user.email,
                    type: @user.type.name,
                    organizations: user_organizations }
      get "/user/#{@user.id}"
      expect_status 200
      expect(response.body).to eql user_json.to_json
    end

    it 'should return 404 if no user found' do
      get "/user/#{User.maximum(:id).to_i.next}"
      expect_status 404
      expect_json(message: 'User not found')
    end
  end

  context 'GET /user' do
    it 'should return 401 Unauthorized if there is no session created' do
      get '/user'
      expect_status 401
      expect_json error: 'Unauthorized'
    end

    it 'should return current authenticated user' do
      post '/session', params: { email: 'some.email@gmail.com',
                                 uuid: @client.key,
                                 password: JWT.encode('some.password', @client.key)}
      expect_status 201
      user_json = { email: @user.email,
                    type: @user.type.name,
                    organizations: user_organizations }
      get '/user', params:  nil,
                   headers: { 'Authorization' => JSON.parse(response.body)['token'] }
      expect_status 200
      expect(response.body).to eql user_json.to_json
    end
  end

  context 'PUT /user/email/:id' do
    it 'should have email parameter' do
      put "/user/email/#{@user.id}", params: { value: Faker::Internet.email }
      expect_status 200
      expect(response.body).to eql 'OK'.to_json
    end

    it 'should return 400 if there is no parameter' do
      put "/user/email/#{@user.id}"
      expect_status 400
      error_response = { error: 'Value parameter empty' }.to_json
      expect(response.body).to eql error_response
    end

    it 'should return 404 if no user found' do
      put "/user/email/#{@user.id + 1}", params: { value: Faker::Internet.email }
      expect_status 404
      error_response = { error: 'User not found' }.to_json
      expect(response.body).to eql error_response
    end
  end

  context 'PUT /user/email' do
    before do
      @new_email = Faker::Internet.email
    end

    it 'should return 401 if not authenticated' do
      put '/user/email', params: { value: @new_email }
      expect_status 401
    end

    it 'should have email parameter' do
      post '/session', params: { email:    'some.email@gmail.com',
                                 password: 'some.password' }
      expect_status 201
      put '/user/email', params:  { value: @new_email },
                         headers: { 'Authorization' => JSON.parse(response.body)['token'] }

      expect_status 200
      expect(response.body).to eql 'OK'.to_json
    end
  end

  context 'POST /user/organizations' do
    before do
      @organization = Organization.create!(name: Faker::Company.name)
    end

    it 'should return 404 if organization does not exist' do
      post '/user/organizations', params: { organization_id: @organization.id + 1,
                                            user_id:         @user.id }
      expect_status 404
      expect_json error: 'Organization missing'
    end

    it 'should be able to add new organization' do
      post '/user/organizations', params: { organization_id: @organization.id,
                                            user_id:         @user.id }
      expect_status 201
      expect(response.body).to eql 'OK'.to_json
    end
  end

  context 'DELETE /user/:id' do
    def create_mock_user(type)
      password = Faker::Internet.password
      user = User.create(email: Faker::Internet.email,
                         type: UserType.create!(name: type),
                         password: password)
      { user: user, password: password }
    end

    def delete_user_by_admin
      admin = create_mock_user('ADMIN')
      post '/session', params: { email:    admin[:user].email,
                                 password: admin[:password] }
      expect_status 201
      user = create_mock_user('USER')[:user]
      delete "/user/#{user.id}", headers: { 'Authorization' => JSON.parse(response.body)['token'] }
      user.id
    end

    it 'should respond with 401 if current user is not ADMIN' do
      user = create_mock_user('USER')[:user]
      delete "/user/#{user.id}"
      expect_status 401
      expect_json error: 'Unauthorized'
    end

    it 'should respond with 200 if current user is ADMIN' do
      delete_user_by_admin
      expect_status 200
      expect(response.body).to eql 'OK'.to_json
    end

    it 'should remove the selected user' do
      user_id = delete_user_by_admin
      get "/user/#{user_id}"
      expect_status 404
    end
  end
end
