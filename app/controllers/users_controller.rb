class UsersController < ApplicationController
  before_action :admin_authorized?, only: [:update_user_field_by_id, :delete_user]
  before_action :user_authorized?, only: [:get_users,
                                          :get_user_by_id,
                                          :update_current_user,
                                          :get_current_user,
                                          :add_user_organization]

  def_param_group :field_value do
    param :field, String, required: true, desc: 'Indicates field that needs to be updated'
    param :value, String, required: true, desc: 'Indicates value of the field'
  end

  # POST /register or
  # POST /user (if user.type == 'ADMIN')
  api :POST, '/register', 'Register new user. Also it can be used by ADMIN as `POST /user` in order to specify user type'
  param :email, String, required: true
  param :password, String, required: true
  header :Cookie, 'Provide `uuid` key as cookie', required: true
  error code: 422, desc: 'Unprocessable Entity, in case values ain\'t valid'
  formats ['application/json']
  def create
    main_params = registration_params.except :type_id, :date_of_birth, :password
    user = User.create!(main_params) do |user|
      user.type = if admin? && params[:type_id]
                    UserType.find(registration_params[:type_id])
                  else
                    UserType.find_by_name('USER')
                  end
      user.password = credentials[:password]
      user.date_of_birth = Date.parse(registration_params[:date_of_birth])
    end
    authentication ||= AuthenticationService.call(credentials)
    render json: { token: authentication.result } if authentication.success?
  end

  # GET /users
  api :GET, '/users', 'Returns a list of users'
  param :limit, String, required: false, desc: 'Set the limit for users list. Default value is 25'
  param :offset, String, required: false, desc: 'Set the offset for users list'
  formats ['application/json']
  def get_users
    users = if params[:offset]
              User.limit(limit).includes(:organizations, :type)
                  .offset(params[:offset])
            else
              User.limit(limit).includes(:organizations, :type)
            end
    response = users.each_with_object([]) do |user, arr|
      arr << format_user(user)
    end
    render json: response, status: :ok
  end

  # GET /user/:id
  api :GET, '/user/:id', 'Returns specific users data'
  param :id, nil, required: true, desc: 'Indicates ID of the user'
  error code: 404, desc: 'User with specified ID wasn`t found'
  formats ['application/json']
  def get_user_by_id
    user = User.find(params[:id])
    render json: format_user(user) if user
  end

  # GET /user
  api :GET, '/user', 'Returns current user data'
  header :Authorization, 'Token for current user', required: true
  error code: 401, desc: 'Unauthorized'
  formats ['application/json']
  def get_current_user
    return render json: format_user(current_user) if current_user
  end

  # PUT /user/:id/:field
  api :PUT, '/user/:id/:field', 'Updates a field of data for specific user'
  param :id, String, required: true, desc: 'Indicates the user to be updated'
  param_group :field_value
  header :Authorization, 'Token for ADMIN', required: true
  error code: 401, desc: 'Unauthorized'
  error code: 404, desc: 'User not found'
  error code: 422, desc: 'Field`s value not valid'
  formats ['application/json']
  def update_user_field_by_id
    return error!(400, message: 'Invalid field') unless valid_field?
    render_ok if User.find(params[:id]).update!(updatable_field)
  end

  # PUT /user/:field
  api :PUT, '/user/:field', 'Updates current session user `:field` value'
  param_group :field_value
  header :Authorization, 'Token for current user', required: true
  error code: 401, desc: 'Unauthorized'
  error code: 422, desc: 'Field`s value not valid'
  formats ['application/json']
  def update_current_user
    return error!(400, message: 'Invalid field') unless valid_field?
    render_ok if current_user.update!(updatable_field)
  end

  # POST /user/organization
  api :POST, '/user/organization', 'Adds a user to organization'
  param :organization_id, String, desc: 'Indicates organization by ID', required: true
  param :user_id, String, desc: 'Indicates user by ID. If it is not indicated it takes current user ID', required: false
  header :Authorization, 'Token for current user', required: true
  error code: 404, desc: 'User or Organization was not found'
  error code: 422, desc: 'User was already added to indicated organization'
  formats ['application/json']
  def add_user_organization
    organization = Organization.find(params[:organization_id])
    user = params[:user_id].present? ? User.find(params[:user_id]) : current_user
    return error!(404, message: 'User not found') unless user
    return error!(422, message: 'Already exists') if
      user.organizations.any? { |org| org.id.eql?(params[:organization_id]) }
    user.organizations << organization
    render_ok if user.save
  end

  # DELETE /user/:id
  api :DELETE, '/user/:id', 'Remove user by ID.'
  param :id, Integer, desc: 'Indicates user by ID', required: true
  formats ['application/json']
  header :Authorization, 'Token for ADMIN', required: true
  error code: 401, desc: 'Unauthorized'
  error code: 404, desc: 'User not found'
  def delete_user
    render_ok if User.find(params[:id]).destroy
  end

  private

  def valid_field?
    !%w(organizations type organization_id type_id password).include?(params[:field])
  end

  def registration_params
    params.permit(:email, :type_id, :first_name, :last_name,
                  :middle_name, :date_of_birth, :avatar)
  end
end
