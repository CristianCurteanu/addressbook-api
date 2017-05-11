module AddressBook
  class UsersResource < Grape::API
    helpers do
      def format_user(user)
        datas = user.attributes.slice(*user_data.map(&:to_s))
                    .merge(type: user.type.name,
                           organizations: user.organizations.select(:id, :name))
        datas.delete_if { |_k, v| v.nil? }
      end
    end

    # GET /users
    params do
      optional :limit, type: Integer
      optional :start, type: Integer
    end
    desc 'Get a list of all users' do
      detail 'You can specify limit and offset (`start` parameter)'
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
      desc 'Find user by :id and get information'
      get ':id' do
        user = User.find_by_id(params[:id])
        user.nil? ? error!({ message: 'User not found' }, 404) : format_user(user)
      end

      # GET /user
      desc 'Return current user information'
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
        requires :uuid
        optional :type_id
        optional :first_name
        optional :last_name
        optional :middle_name
        optional :date_of_birth
        optional :avatar

        optional :organizations, type: Array[Integer]
      end
      desc 'Create user' do
        detail 'Only Admin user can use this endpoint'
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
        requires :id
        all_or_none_of :field, :value
      end
      desc 'Update user by :id' do
        detail 'Only Admin user can use this endpoint'
      end
      put ':id/:field' do
        error!('Unauthorized', 401) unless admin?
        user = User.find_by_id(params[:id])
        return error!('User not found', 404) unless user
        'OK' if user.update(params[:field].to_sym => params[:value])
      end

      # PUT /user/:field
      desc 'Update current user'
      params do
        requires :field, type: String, message: 'unknown'
        requires :value, type: String, message: :value_required
        all_or_none_of :field, :value
      end
      put ':field' do
        return error!('Unauthorized', 401) unless current_user
        'OK' if current_user.update(params[:field].to_sym => params[:value]) &&
                !%w(organizations type organization_id type_id).include?(params[:field])
      end

      # POST /user/organization
      desc 'Connect user and organization by user_id and organization_id'
      params do
        requires :organization_id, type: Integer
        optional :user_id, type: Integer
      end
      post :organizations do
        return error!('Organization missing', 404) unless Organization.find_by_id(params[:organization_id])
        return error!('No user found', 404) unless params[:user_id] || current_user
        user = params[:user_id].present? ? User.find_by_id(params[:user_id]) : current_user
        return { message: 'Already exists' } if
          user.organizations.any? { |org| org.id.eql?(params[:organization_id]) }
        user.organizations << Organization.find_by_id(params[:organization_id])
        'OK' if user.save
      end

      # DELETE /user/:id
      desc 'Remove specified user' do
        detail 'User can be removed only by admin, and it should be specified :id of the user'
      end
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
