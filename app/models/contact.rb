class Contact
  include Virtus.model
  include ActiveModel::Serialization
  include ActiveModel::Validations

  attribute :name, String
  attribute :address, Hash
  attribute :contacts
  attribute :organization, Organization

  def get
    client.get("organization/#{organization.id}").body
  end

  def save
    client.
  end

  def update
    
  end

  private 

  def client
    if Rails.env.test? 
      Firebase::Client.new 'https://example.firebase.com'
    else 
      Firebase::Client.new 'https://address-book-c120b.firebaseio.com/'
    end
  end
end