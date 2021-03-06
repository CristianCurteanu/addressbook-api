module MockHelper
  def token_for(type)
    user = create_mock_user(type.to_s.upcase)
    post '/session', params: { email: user[:user].email,
                               password: JWT.encode(user[:user].password, @client.key) },
                     headers: { Accept: 'application/json',
                                Cookie: "uuid=#{@client.uuid}" }
    expect_status 200
    JSON.parse(response.body)['token']
  end

  def create_mock_user(type)
    password = Faker::Internet.password
    user = User.create(email: Faker::Internet.email,
                       type: UserType.create!(name: type),
                       password: password)
    { user: user, password: password }
  end

  def organization_by_id(id)
    "https://example.firebase.com/organization/#{id}.json"
  end

  def delete_user_by_admin
    user = create_mock_user('USER')[:user]
    delete "/user/#{user.id}", headers: { Authorization: token_for(:admin),
                                          Accept: 'application/json' }
    user.id
  end

  def new_contact
    { SecureRandom.uuid => { value: Faker::Internet.email } }
  end
end
