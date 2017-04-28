require 'rails_helper'

describe AddressBook::UsersResource do

  before(:all) do 
    @user ||= User.create!(email: 'some.email@gmail.com',
                           type: UserType.create!(name: 'USER'),
                           password: 'some.password')
    @user.organizations << Organization.create!(name: 'Some Organization Inc.')
    @user.organizations << Organization.create!(name: 'Second Organization Inc.')
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
      post '/session', params: {email: 'some.email@gmail.com', 
                                password: 'some.password'}
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
end
