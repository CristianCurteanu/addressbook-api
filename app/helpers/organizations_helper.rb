module OrganizationsHelper
  def format_organization(organization)
    {
      id: organization.id,
      name: organization.name,
      contacts: organization.contacts.get
    }
  rescue
    {}
  end
end
