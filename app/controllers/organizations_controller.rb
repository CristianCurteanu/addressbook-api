class OrganizationsController < ApplicationController
  before_action :admin_authorized?, only: [:create, :destroy]
  before_action :user_authorized?, only: [:post_organization_contact,
                                          :update_organization_contact,
                                          :update_organization,
                                          :delete_organization_contacts]

  before_action only: :post_organization_contact do
    error!(400, { error: 'Organization ID or data missing' }) if
      params[:data].nil? || params[:organization_id].nil?
  end

  # GET /organizations
  api :GET, '/organizations', 'Returns a list of organizations'
  param :limit, Integer, desc: 'Set list limit. Default value 25'
  param :offset, Integer, desc: 'Set lists` offset.'
  error code: 404, desc: 'No organization found'
  formats ['application/json']
  def get_organizations
    organizations = if params[:offset]
                      Organization.limit(limit).offset(params[:offset])
                    else
                      Organization.limit(limit)
                    end
    response = organizations.each_with_object([]) do |organization, result|
      result << format_organization(organization)
    end
    return render json: response, status: 200 unless response.empty?
    error! 404, { error: 'No organization found' }
  end

  # GET /organization/:id
  api :GET, '/organization/:id', 'Return specific organization data'
  param :id, Integer, required: true, desc: 'Specify organization id'
  formats ['application/json']
  error code: 404, desc: 'Organization with specified :id not found'
  def get_organization_by_id
    render json: format_organization(Organization.find(params[:id]))
  end

  # POST /organization
  api :POST, '/organization', 'Creates new organization'
  header :Authorization, 'Token for Admin', required: true
  param :name, String, required: true, desc: 'Sets organization name'
  error code: 422, desc: 'Validation exception'
  error code: 401, desc: 'Unauthorized'
  formats ['application/json']
  def create
    render_ok if Organization.create!(organization_params)
  end

  # POST /organization/contact
  api :POST, '/organization/contact', 'Creates new contact for specific organization'
  header :Authorization, 'Token for current user', required: true
  param :organization_id, Integer, required: true, desc: 'Specify organization by ID'
  param :data, String, required: true, desc: 'Contact data as JSON serialized object with name of contact as key, ex:
                                       {"John Smith": { "email": "john.smith@gmail.com" }}'
  error code: 401, desc: 'Unauthorized'
  error code: 404, desc: 'No organization found'
  error code: 409, desc: 'Organization already have a contact with specified key'
  formats ['application/json']
  def post_organization_contact
    if Organization.find(new_contact_params[:organization_id]).contacts.add(params[:data])
      render_ok
    else
      error! 409, message: 'This company already has that contact'
    end
  end

  # PUT /organization/:id/:field
  api :PUT, '/organization/:id/:field', 'Updates organization data by field name'
  header :Authorization, 'Token for current user', required: true
  param :id, Integer, required: true, desc: 'Indicates the Organization ID'
  param :field, String, required: true, desc: 'Indicates field that needs to be updated'
  param :value, String, required: true, desc: 'Indicates value of the field'
  error code: 400, desc: 'Update failed'
  error code: 401, desc: 'Unauthorized'
  error code: 404, desc: 'Organization not found'
  error code: 422, desc: 'Invalid value passed'
  formats ['application/json']
  def update_organization
    if Organization.find(params[:id]).update!(updatable_field)
      render_ok
    else
      error! 400, message: 'Update failed'
    end
  end

  # PUT /organization/contact
  api :PUT, '/organization/contact',
            'Updates contact data for specifi organization by key'
  header :Authorization, 'Token for current user', required: true
  param :id, Integer, required: true, desc: 'Indicates organization ID'
  param :key, String, required: true, desc: 'Indicates contact which should be updated'
  param :data, String, required: true, desc: 'Provide the data which will replace existing data. Note: it will replace whole object'
  error code: 401, desc: 'Unauthorized'
  error code: 400, desc: 'Update failed'
  error code: 404, desc: 'Organization not found'
  formats ['application/json']
  def update_organization_contact
    if Organization.find(params[:id]).contacts.update(params[:key], params[:data])
      render_ok
    else
      error! 400, message: 'Update failed'
    end
  end

  # DELETE /organization/:id
  api :DELETE, '/organization/:id', 'Delete organization by ID'
  header :Authorization, 'Token for Admin user', required: true
  param :id, Integer, required: true, desc: 'Specify the organization by ID'
  error code: 401, desc: 'Unauthorized'
  error code: 404, desc: 'Organization not found'
  formats ['application/json']
  def destroy
    organization = Organization.find(params[:id])
    render_ok if organization.contacts.delete_all && organization.delete
  end

  # DELETE /organization/:id/contacts
  api :DELETE, '/organization/:id/contacts', 'Empty all contacts for specific organization'
  header :Authorization, 'Token for current user', required: true
  param :id, Integer, required: true, desc: 'Specify the organization by ID'
  error code: 400, desc: 'Failed to delete contacts'
  error code: 401, desc: 'Unauthorized'
  error code: 404, desc: 'Organization not found'
  formats ['application/json']
  def delete_organization_contacts
    return render_ok if Organization.find(params[:id]).contacts.delete_all
    error 400, error: 'Failed to delete contacts'
  end

  # DELETE /organization/:id/contact
  api :DELETE, '/organization/:id/contact', 'Remove specific contact of a specific organization'
  header :Authorization, 'Token for current user', required: true
  param :id, Integer, required: true, desc: 'Specify the organization by ID'
  param :key, String, required: true, desc: 'Specify contact by key'
  error code: 404, desc: 'Organization or Contact for specific organization not found'
  error code: 401, desc: 'Unauthorized'
  formats ['application/json']
  def delete_organization_contact
    return render_ok if Organization.find(params[:id]).contacts.delete(params[:key])
    error! 404, error: 'Such key not found'
  end

  private

  def organization_params
    params.permit(:name)
  end

  def new_contact_params
    params.permit(:organization_id)
  end
end
