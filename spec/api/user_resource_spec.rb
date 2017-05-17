require 'rails_helper'

describe 'Users' do
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
      user_json = { id: @user.id,
                    email: @user.email,
                    type: @user.type.name,
                    organizations: user_organizations }
      get "/user/#{@user.id}", headers: { Accept: 'application/json' }
      expect_status 200
      expect(response.body).to eql user_json.to_json
    end

    it 'should return 404 if no user found' do
      id = User.maximum(:id).to_i.next
      get "/user/#{id}", headers: { Accept: 'application/json' }
      expect_status 404
      expect_json(message: "Couldn't find User with 'id'=#{id}")
    end
  end

  context 'GET /user' do
    it 'should return 401 Unauthorized if there is no session created' do
      get '/user', headers: { Accept: 'application/json' }
      expect_status 401
      expect_json error: 'Unauthorized'
    end

    it 'should return current authenticated user' do
      post '/session', params: { email: 'some.email@gmail.com',
                                 password: JWT.encode('some.password', @client.key) },
                       headers: { Accept: 'application/json',
                                  Cookie: "uuid=#{@client.uuid}" }
      expect_status 200
      user_json = { id:    @user.id,
                    email: @user.email,
                    type:  @user.type.name,
                    organizations: user_organizations }
      get '/user', params:  nil,
                   headers: { Accept: 'application/json',
                              Authorization: JSON.parse(response.body)['token']}
      expect_status 200
      expect(response.body).to eql user_json.to_json
    end
  end

  context 'PUT /user/email/:id' do
    it 'should have email parameter' do
      put "/user/#{@user.id}/email", params: { value: Faker::Internet.email },
                                     headers: { Authorization: token_for(:admin),
                                                Accept: 'application/json' }
      expect_status 200
      expect(response.body).to eql({ message: 'OK'}.to_json)
    end

    it 'should return 400 if there is no parameter' do
      put "/user/#{@user.id}/email", headers: { Authorization: token_for(:admin),
                                                Accept: 'application/json' }
      expect_status 422
      error_response = { message: { email: ["can't be blank", "is invalid"] } }
      expect(response.body).to eql error_response.to_json
    end
  end

  context 'PUT /user/email' do
    before do
      @new_email = Faker::Internet.email
    end

    it 'should return 401 if not authenticated' do
      put '/user/email', params: { value: @new_email },
                         headers: { Accept: 'application/json' }
      expect_status 401
    end

    it 'should have email parameter' do
      post '/session', params: { email: 'some.email@gmail.com',
                                 password: JWT.encode('some.password', @client.key) },
                       headers: { Accept: 'application/json',
                                  Cookie: "uuid=#{@client.uuid}" }
      expect_status 200
      put '/user/email', params:  { value: @new_email },
                         headers: { Authorization: JSON.parse(response.body)['token'],
                                    Accept: 'application/json' }

      expect_status 200
      expect(response.body).to eql({ message: 'OK' }.to_json)
    end
  end

  context 'POST /user/organization' do
    before do
      @organization = Organization.create!(name: Faker::Company.name)
    end

    it 'should return 404 if organization does not exist' do
      post '/user/organization', params: { organization_id: @organization.id + 1,
                                            user_id:         @user.id },
                                 headers: { Accept: 'application/json' }
      expect_status 404
    end

    it 'should be able to add new organization' do
      post '/user/organization', params: { organization_id: @organization.id,
                                            user_id:         @user.id },
                                 headers: { Accept: 'application/json' }
      expect_status 200
      expect(response.body).to eql({ message: 'OK' }.to_json)
    end
  end

  context 'DELETE /user/:id' do
    it 'should respond with 401 if current user is not ADMIN' do
      user = create_mock_user('USER')[:user]
      delete "/user/#{user.id}", headers: { Accept: 'application/json' }
      expect_status 401
      expect_json error: 'Unauthorized'
    end

    it 'should respond with 200 if current user is ADMIN' do
      delete_user_by_admin
      expect_status 200
      expect(response.body).to eql({message: 'OK'}.to_json)
    end

    it 'should remove the selected user' do
      user_id = delete_user_by_admin
      get "/user/#{user_id}", headers: { Accept: 'application/json' }
      expect_status 404
    end
  end
end
