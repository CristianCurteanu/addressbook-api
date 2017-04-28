require "rails_helper"

describe User, type: :model do
  let(:valid_email) do 
    'some.valid@email.com'
  end

  let(:valid_user_type) do 
    UserType.new(id: 1, name: 'USER')
  end

  before do 
    @user = User.new(email: valid_email, type: valid_user_type)
  end

  it 'should have one user type association' do 
    should belong_to(:type)
  end

  it 'should have and belong to many organizations' do 
    should have_and_belong_to_many(:organizations)
  end

  it 'is not valid without email' do 
    expect(@user).to be_valid
    expect(User.new(email: nil)).not_to be_valid
  end

  it 'should have a right email format' do 
    ['random.text@', '@google.com'].each do |email|
      expect(User.new(email: email)).not_to be_valid
    end
  end

  it 'should be able to add new organization' do 
    @user.organizations << 
      Organization.new(name: 'Sample Organization Inc')
    expect(@user.organizations).to be_present
  end
end