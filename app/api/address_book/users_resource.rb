module AddressBook
  class UsersResource < Grape::API
    resource :user do

      helpers do 
        def format_user(user)
          { email: user.email, 
            type: user.type.name, 
            organizations: user.organizations.select(:id, :name) 
          }
        end
      end

      get ':id' do 
        user = User.find_by_id(params[:id])
        user.nil? ? error!({message: 'User not found'}, 404) : format_user(user)
      end

      get do 
        if current_user.nil?
          error!('Unauthorized', 401)
        else
          format_user current_user
        end
      end
    end
  end
end
