require 'rails_helper'

describe AddressBook::UsersResource do 
  context 'GET /user/:id' do 
    it 'should return a user by id' do 
      user = User.create!(email: 'some.email@gmail.com', 
                          type: UserType.create!(name: 'USER'))
      get "/user/#{user.id}"
      expect_status 200
      expect_json(user.as_json)
    end

    it 'should return 404 if no user found' do
      get "/user/#{User.maximum(:id).to_i.next}"
      expect_status 404
      expect_json(message: 'There is no user with this id')
    end

    context 'GET /user' do 
      it 'should return 401 Unauthorized if there is no session created' do 
        get '/user' 
        expect_status 401
        expect_json message: 'Unauthorized'
      end

      it 'should return current session user' do 
        
      end
    end
  end
end