module AddressBook
  class OrganizationResource < Grape::API

    helpers do 
      def wrap_up(organization)
        { 
          id: organization.id,
          name: organization.name,
          contacts: organization.contacts.get
        }
      rescue
        {}
      end
    end

    # GET /organizations
    desc 'Return list of all organizations'
    get :organizations do 
      organizations = Organization.limit(params[:limit] || 10).order('id DESC')
      organizations.each_with_object([]) do |organization, result|
        result << wrap_up(organization)
      end  
    end

    resource :organization do

      desc 'Find organization by :id'
      # GET /organization/:id
      params do 
        requires :id, type: Integer
      end
      get ':id' do
        wrap_up Organization.find(params[:id])
      end

      desc 'Create new organization'
      # POST /organization
      params do
        requires :name, type: String
      end
      post do 
        error!('Unauthorized', 401) unless admin?
        organization = Organization.new(name: params[:name])
        { message: 'OK' } if organization.save
      end

      # POST /organization/contact
      desc 'Add organization contact' do 
        detail 'Find organization by organization_id parameter, and update with data. 
                  Data can have any JSON structure that client application is comfortable with'
      end
      params do
        requires :data, type: JSON
        requires :organization_id
      end
      post :contact do
        error!('Unauthorized', 401) unless current_user
        organization = Organization.find(params[:organization_id])
        { message: 'OK' } if organization.contacts.add(params[:data])
      end

      # PUT /organization/:id/:field
      desc 'Update organization contact'
      params do
        requires :id, type: Integer
        requires :field, type: String
      end
      put ':id/:field' do 
        organization = Organization.find(params[:id])
        { message: 'OK' } if organization.update(params[:field].to_sym => params[:value])
      end

      # PUT /organization/contacts
      desc 'Update contact information' do 
        detail 'Specify :name of object, :data which should be updated and organization :id'
      end
      params do
        requires :id
        requires :data
        requires :key
      end
      put 'contacts' do 
        organization = Organization.find(params[:id])
        { message: 'OK' } if organization.contacts.update(params[:key], params[:data])
      end

      # DELETE /organization/:id
      desc 'Delete specified company' do 
        detail 'Admin access only'
      end
      params do 
        requires :id, type: Integer
      end
      delete ':id' do
        error!('Unauthorized', 401) unless admin?
        organization = Organization.find(params[:id])
        organization.contacts.delete_all
        { message: 'OK' } if organization.delete
      end

      # DELETE /organization/:id/contacts
      desc 'Delete all contacts for organization specified by :id'
      params do 
        requires :id, type: Integer
      end
      delete ':id/contacts' do
        error!('Unauthorized', 401) unless current_user
        { message: 'OK' } if Organization.find(params[:id]).contacts.delete_all
      end

      # DELETE /organization/:id/contact
      desc 'Delete single contact data' do 
        detail 'For contact data stored by :key value and organization with specific :id'
      end
      params do
        requires :id, type: Integer
        requires :key, type: String
      end
      delete ':id/contact' do
        key = params[:key]
        { message: 'OK' } if Organization.find(params[:id]).contacts.delete(key)
      end
    end
  end
end
