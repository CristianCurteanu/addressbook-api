module AddressBook
  class UsersResource < Grape::API
    resource :user do
      helpers do
        def format_user(user)
          { email: user.email,
            type: user.type.name,
            organizations: user.organizations.select(:id, :name) }
        end
      end

      get ':id' do
        user = User.find_by_id(params[:id])
        user.nil? ? error!({ message: 'User not found' }, 404) : format_user(user)
      end

      get do
        if current_user.nil?
          error!('Unauthorized', 401)
        else
          format_user current_user
        end
      end

      params do
        requires :field, type: String, message: 'unknown'
        requires :value, type: String, message: :value_required
        optional :id
        all_or_none_of :field, :value
      end
      put ':field/:id' do
        user = User.find_by_id(params[:id])
        return error!('User not found', 404) unless user
        'OK' if user.update(params[:field].to_sym => params[:value])
      end

      params do
        requires :field, type: String, message: 'unknown'
        requires :value, type: String, message: :value_required
        all_or_none_of :field, :value
      end
      put ':field' do
        return error!('Unauthorized', 401) unless current_user
        'OK' if current_user.update(params[:field].to_sym => params[:value])
      end

      params do
        requires :organization_id, type: Integer
        optional :user_id, type: Integer
      end
      post :organizations do
        return error!('Organization missing', 404) unless Organization.find_by_id(params[:organization_id])
        return error!('No user found', 404) unless params[:user_id] || current_user
        user = params[:user_id].present? ? User.find_by_id(params[:user_id]) : current_user
        'OK' if user.organizations << Organization.find_by_id(params[:organization_id])
      end

      params do
        requires :id, type: Integer
      end
      delete ':id' do
        error!('Unauthorized', 401) unless current_user && current_user.type.name == 'ADMIN'
        'OK' if User.find(params[:id]).destroy
      end
    end
  end
end
