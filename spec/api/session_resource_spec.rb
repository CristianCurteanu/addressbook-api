require 'rails_helper'

describe 'Sessions' do
  before(:all) do
    email = Faker::Internet.email
    uuid = SecureRandom.uuid
    @client = Client.create!(email: email,
                             uuid:  uuid,
                             key: JWT.encode(email, uuid))
  end

  context 'POST /session' do
    before do
      @user = create_mock_user('ADMIN')[:user]
    end

    it 'should create new session' do
      post '/session', params: { email: @user.email,
                                 password: JWT.encode(@user.password, @client.key) },
                       headers: { Accept: 'application/json',
                                  Cookie: "uuid=#{@client.uuid}" }
      expect_status 200
      get '/user', headers: { Accept: 'application/json',
                              Authorization: JSON.parse(response.body)['token'] }
      expect_status 200
    end
  end

  context 'DELETE /session' do
    before do
      @session_token = token_for :user
    end

    it 'should remove session' do
      get '/user', headers: { Accept: 'application/json',
                              Authorization: @session_token }
      expect_status 200
      delete '/session', headers: { Accept: 'applcation/json',
                                    Authorization: @session_token }
      get '/user', headers: { Accept: 'application/json',
                              Authorization: @session_token }
      expect_status 401
    end
  end
end