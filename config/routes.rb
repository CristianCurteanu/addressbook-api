Rails.application.routes.draw do
  apipie
  resource :session, only: [:create, :destroy]
  post 'register', to: 'users#create'
  post 'client/token', to: 'client_applications#create'

  # Users resources
  post 'user', to: 'users#create'
  get 'users', to: 'users#get_users'
  get 'user', to: 'users#get_current_user'
  get 'user/:id', to: 'users#get_user_by_id'
  put 'user/:id/:field', to: 'users#update_user_field_by_id'
  put 'user/:field', to: 'users#update_current_user'
  post 'user/organization', to: 'users#add_user_organization'
  delete 'user/:id', to: 'users#delete_user'

  # Organizations resources
  get 'organizations', to: 'organizations#get_organizations'
  get 'organization/:id', to: 'organizations#get_organization_by_id'
  post 'organization', to: 'organizations#create'
  post 'organization/contact', to: 'organizations#post_organization_contact'
  put 'organization/:id/:field', to: 'organizations#update_organization'
  put 'organization/contact', to: 'organizations#update_organization_contact'
  delete 'organization/:id', to: 'organizations#destroy'
  delete 'organization/:id/contact', to: 'organizations#delete_organization_contact'
  delete 'organization/:id/contacts', to: 'organizations#delete_organization_contacts'
end
