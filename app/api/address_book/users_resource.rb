module AddressBook
  class UsersResource < Grape::API

    helpers do
      def format_user(user)
        datas = user.attributes.slice(*user_data.map(&:to_s))
          .merge(type: user.type.name,
                 organizations: user.organizations.select(:id, :name))
        datas.delete_if { |k, v| v.nil? }
      end
    end

    # GET /users
    params do
      optional :limit, type: Integer
      optional :start, type: Integer
    end
    get :users do
      # TODO: REFACTOR THIS!!!
      users = if params[:limit]
                if params[:start]
                  Users.limit(params[:limit]).offset(params[:offset])
                else
                  Users.limit(params[:limit])
                end
              else
                User.all
              end
      users.each_with_object([]) do |user, arr|
        arr << format_user(user)
      end
    end

    resource :user do

      # GET /user/:id
      desc 'REST Post with attributes param.'
      get ':id' do
        user = User.find_by_id(params[:id])
        user.nil? ? error!({ message: 'User not found' }, 404) : format_user(user)
      end

      # GET /user
      get do
        if current_user.nil?
          error!('Unauthorized', 401)
        else
          format_user current_user
        end
      end

      # POST /user
      params do 
        requires :email, type: String
        requires :password, type: String
        requires :type_id, type: Integer

        requires :email, type: String
        requires :password
        requires :key
        optional :type_id
        optional :first_name
        optional :last_name
        optional :middle_name 
        optional :date_of_birth 
        optional :avatar

        optional :organizations, type: Array[Integer]
      end
      post do
        error!('Unauthorized', 401) unless admin?
        user = User.new(registration_params)
        params[:organizations].each do
          user.organizations << Organization.find(id)
        end
        'OK' if user.save
      end

      # PUT /user/:id/:field
      params do
        requires :field, type: String, message: 'unknown'
        requires :value, type: String, message: :value_required
        optional :id
        all_or_none_of :field, :value
      end
      put ':id/:field' do
        user = User.find_by_id(params[:id])
        return error!('User not found', 404) unless user
        'OK' if user.update(params[:field].to_sym => params[:value])
      end

      # PUT /user/:field
      params do
        requires :field, type: String, message: 'unknown'
        requires :value, type: String, message: :value_required
        all_or_none_of :field, :value
      end
      put ':field' do
        return error!('Unauthorized', 401) unless current_user
        'OK' if current_user.update(params[:field].to_sym => params[:value]) &&
          !['organizations', 'type', 'organization_id', 'type_id'].include?(params[:field])
      end

      # POST /user/organization
      params do 
        requires :organization_id, type: Integer
        optional :user_id, type: Integer
      end
      post :organizations do
        return error!('Organization missing', 404) unless Organization.find_by_id(params[:organization_id])
        return error!('No user found', 404) unless params[:user_id] || current_user
        user = params[:user_id].present? ? User.find_by_id(params[:user_id]) : current_user
        return {message: 'Already exists'} if 
          user.organizations.any? { |org| org.id.eql?(params[:organization_id])}
        user.organizations << Organization.find_by_id(params[:organization_id])
        'OK' if user.save
      end

      # DELETE /user/:id
      params do 
        requires :id, type: Integer
      end
      delete ':id' do 
        error!('Unauthorized', 401) unless admin?
        'OK' if User.find(params[:id]).destroy
      end
    end
  end
end
