require 'rails_helper'

describe Client, type: :model do
  before(:each) do
    email = Faker::Internet.email
    uuid = SecureRandom.uuid
    @fields = { email: email, uuid: uuid, key: JWT.encode(email, uuid) }
  end

  it 'should have uuid' do
    expect(described_class.new(@fields.slice(:uuid))).not_to be_valid
  end

  it 'should have key' do
    expect(described_class.new(@fields.slice(:key))).not_to be_valid
  end
  it 'should have email' do
    expect(described_class.new(@fields.slice(:email))).not_to be_valid
  end
end
