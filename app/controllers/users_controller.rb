class UsersController < ApplicationController
  before_action :admin_authorized?, only: [:update_user_field_by_id, :delete_user]
  before_action :user_authorized?,
                only: [:update_current_user, :get_current_user]

  # POST /register or
  # POST /user (if user.type == 'ADMIN')
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
  def get_users
    limit = params[:limit] || 25
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
  def get_user_by_id
    user = User.find(params[:id])
    render json: format_user(user) if user
  end

  # GET /user
  def get_current_user
    return render json: format_user(current_user) if current_user
  end

  # PUT /user/:id/:field
  def update_user_field_by_id
    return error!(400, message: 'Invalid field') unless valid_field?
    render_ok if User.find(params[:id]).update!(updatable_field)
  end

  # PUT /user/:field
  def update_current_user
    return error!(400, message: 'Invalid field') unless valid_field?
    render_ok if current_user.update!(updatable_field)
  end

  # POST /user/organization
  def add_user_organization
    organization = Organization.find(params[:organization_id])
    user = params[:user_id].present? ? User.find(params[:user_id]) : current_user
    return error!(422, message: 'Already exists') if
      user.organizations.any? { |org| org.id.eql?(params[:organization_id]) }
    user.organizations << organization
    render_ok if user.save
  end

  # DELETE /user/:id
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
