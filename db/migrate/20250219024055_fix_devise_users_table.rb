class FixDeviseUsersTable < ActiveRecord::Migration[8.0]  # Check your Rails version (adjust if needed)
  def change
    # Remove the old column from BCrypt
    remove_column :users, :password_digest, :string

    # Add the correct Devise column
    add_column :users, :encrypted_password, :string, null: false, default: ""

    # If you need Devise to remember users (optional)
    add_column :users, :remember_created_at, :datetime
  end
end
