module Base
  class API < Grape::API
    format :json
    # rescue_from :all do |error|
      # error!('Internal server error!', 500)
    # end

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
