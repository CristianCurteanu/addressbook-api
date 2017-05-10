class Contact
  include Virtus.model
  include ActiveModel::Serialization
  include ActiveModel::Validations

  attribute :organization, Organization

  def get
    client.get(path).body || []
  end

  def add(contact)
    response = get
    return false if response.select { |k| k.key?(contact.keys[0]) }.length > 2
    client.set(path, response.push(contact))
  end

  def update(key, data)
    response = get
    return false if response.empty?
    response[response.index { |r| r.key?(key) }][key] = data
    client.set(path, response)
  rescue
    false
  end

  def delete(key)
    client.set(path, get.delete_if { |h| h.key?(key)})
  end

  def delete_all
    client.set(path, [])
  end

  private

  def path
    raise 'No organization present' unless organization
    "organization/#{organization.id}"
  end

  def client
    Firebase::Client.new firebase_url, firebase_key
  end

  def firebase_key
    return nil if test_env?
    ENV['FIREBASE_AUTH_KEY'] || '87y0ekfaNaqMEEniTo9CLTeQMtXXWyW4yV8r7XAx'
  end

  def firebase_url
    return 'https://example.firebase.com' if test_env?
    ENV['FIREBASE_URL'] || 'https://address-book-c120b.firebaseio.com/'
  end

  def test_env?
    Rails.env.test?
  end
end