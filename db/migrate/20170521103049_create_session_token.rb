class CreateSessionToken < ActiveRecord::Migration[5.0]
  def change
    create_table :session_tokens do |t|
      t.string :token, unique: true
      t.datetime :expires_at
    end
  end
end
