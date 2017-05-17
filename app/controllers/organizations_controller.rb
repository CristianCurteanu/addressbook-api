class OrganizationsController < ApplicationController
  before_action :admin_authorized?, only: [:create, :destroy]
  before_action :user_authorized?, only: [:post_organization_contact,
                                          :update_organization_contact,
                                          :update_organization,
                                          :delete_organization_contacts]

  # GET /organizations
  def get_organizations
    limit = params[:limit] || 10
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
  def get_organization_by_id
    render json: format_organization(Organization.find(params[:id]))
  end

  # POST /organization
  def create
    render_ok if Organization.create!(organization_params)
  end

  # POST /organization/contact
  def post_organization_contact
    return error!(400, { error: 'Organization ID or data missing' }) if
      params[:data].nil? || params[:organization_id].nil?
    if Organization.find(new_contact_params[:organization_id]).contacts.add(params[:data])
      render_ok
    else
      error! 409, message: 'This company already has that contact'
    end
  end

  # PUT /organization/:id/:field
  def update_organization
    if Organization.find(params[:id]).update!(updatable_field)
      render_ok
    else
      error! 400, message: 'Update failed'
    end
  end

  # PUT /organization/contact
  def update_organization_contact
    if Organization.find(params[:id]).contacts.update(params[:key], params[:data])
      render_ok
    else
      error! 400, message: 'Update failed'
    end
  end

  # DELETE /organization/:id
  def destroy
    organization = Organization.find(params[:id])
    render_ok if organization.contacts.delete_all && organization.delete
  end

  # DELETE /organization/:id/contacts
  def delete_organization_contacts
    render_ok if Organization.find(params[:id]).contacts.delete_all
  end

  # DELETE /organization/:id/contact
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
