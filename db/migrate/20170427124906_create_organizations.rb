class CreateOrganizations < ActiveRecord::Migration[5.0]
  def change
    create_table :organizations do |t|
      t.string :name
      t.text :description

      t.timestamps
    end

    create_table :organizations_users, id: false do |t|
      t.belongs_to :organization, index: true
      t.belongs_to :user, index: true
    end
  end
end
