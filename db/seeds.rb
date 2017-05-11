require 'faker'

# User types
[{name: 'USER'}, 
 {name: 'ADMIN'}].each do |type| 
   UserType.create!(type)
end

# Create Admin
User.create!(email: 'admin@addressbook.com', 
             password: 'test1', 
             type: UserType.find_by_name('ADMIN'))

3.times do
  Organization.create!(name: Faker::Company.name)
end