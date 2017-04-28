module Base
  class API < Grape::API 
    format :json 
    rescue_from :all

    doorkeeper_for :all

    helpers do 
      def current_token
        env['api.token']
      end

      def warden
        env['warden']
      end

      def current_resource_owner
        User.find(current_token.resource_owner_id) if current_token
      end
    end

    mount AddressBook::OrganizationResource
    mount AddressBook::UsersResource
    mount AddressBook::ContactListsResource  
  end
end