module Base
  class API < Grape::API
    format :json
    rescue_from :all do |e|
      if Rails.env.development? || Rails.env.test?
        error!(e, 500)
      else
        error!('Internal server error', 500)
      end
    end

    rescue_from Grape::Exceptions::ValidationErrors do |e|
      error! e.full_messages.first, 400 if Rails.env.development? || Rails.env.test?
    end

    rescue_from ActiveRecord::RecordNotFound do |e|
      error_response(message: e.message, status: 404)
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
        @authentication ||= AuthenticationService.call(params[:email], params[:password])
      end

      def authorization
        @authorization ||= AuthorizationService.call(headers)
      end
    end

    desc 'Authenticate client via email and password parameters'
    params do
      requires :email,    type: String
      requires :password, type: String
    end
    post :session do
      if authentication.success?
        { token: authentication.result }
      else
        error!('Authentication failed', 401)
      end
    end

    mount AddressBook::OrganizationResource
    mount AddressBook::UsersResource
    mount AddressBook::ContactListsResource
  end
end
