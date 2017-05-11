module Base
  class API < Grape::API
    format :json

    add_swagger_documentation #hide_documentation_path: true,
                              #hide_format: true

    rescue_from Grape::Exceptions::ValidationErrors do |e|
      error! e.full_messages.first, 400 if Rails.env.development? || Rails.env.test?
    end

    rescue_from ActiveRecord::RecordNotFound do |e|
      error_response(message: e.message, status: 404)
    end

    rescue_from :all do |e|
      if Rails.env.development? || Rails.env.test?
        error!(e, 500)
      else
        error!('Internal server error', 500)
      end
    end

    content_type :json, 'application/json; charset=UTF-8'

    before do
      header['Access-Control-Allow-Origin'] = '*'
      header['Access-Control-Request-Method'] = '*'
    end

    helpers do
      def current_user
        @current_user ||= authorization.result if authorization.success?
      end

      def authentication
        @authentication ||= AuthenticationService.call(params[:email], password)
      end

      def authorization
        @authorization ||= AuthorizationService.call(headers)
      end

      def admin?
        current_user && current_user.type.name == 'ADMIN'
      end

      def registration_params
        type_name = if params[:type_id]
                      UserType.find(params[:type_id]).name
                    else
                      'USER'          
                    end
        params.slice(*user_data.map(&:to_s)).merge(password: password, 
                                    type:     UserType.find_by_name(type_name))

      end

      def password
        JWT.decode(params[:password], client_key)[0]
      end

      def client_key
        Client.find_by_uuid(cookies[:uuid] || params[:uuid]).key
      end

      def user_data
        [:email, :first_name, :middle_name, :last_name, :date_of_birth, :avatar]
      end
    end

    desc 'Authenticate client via email and password parameters'
    params do
      requires :email,    type: String
      requires :password, type: String
      optional :uuid
    end
    post :session do
      if authentication.success?
        { token: authentication.result }
      else
        error!('Authentication failed', 401)
      end
    end

    params do
      requires :email, type: String
      requires :password
      optional :uuid
      optional :type_id
      optional :first_name
      optional :last_name
      optional :middle_name 
      optional :date_of_birth 
      optional :avatar
    end
    post :register do
      user = User.create!(registration_params)
      { token: authentication.result } if authentication.success?
    end

    params do
      requires :email
    end
    post 'client/token' do
      uuid = SecureRandom.uuid
      datas = { email: params[:email],
                uuid:  uuid, 
                key:   JWT.encode(params[:email], uuid) }
      datas.slice(:uuid) if Client.create!(datas)
    end

    mount AddressBook::OrganizationResource
    mount AddressBook::UsersResource
  end
end
