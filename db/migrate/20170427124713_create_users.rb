class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :user_types do |t|
      t.string :name, unique: true
    end

    create_table :users do |t|
      t.string :email
      t.string :password_digest
      t.string :first_name
      t.string :last_name
      t.string :middle_name
      t.date   :date_of_birth
      t.string :avatar_url
      t.belongs_to :user_type, index: true

      t.timestamps
    end
  end
end
