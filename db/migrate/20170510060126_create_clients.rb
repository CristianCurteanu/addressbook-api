class CreateClients < ActiveRecord::Migration[5.0]
  def change
    create_table :clients do |t|
      t.string :email, unique: true
      t.string :uuid
      t.string :key
    end
  end
end
