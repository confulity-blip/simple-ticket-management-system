class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.integer :role, null: false, default: 2  # 0=admin, 1=agent, 2=customer
      t.string :first_name
      t.string :last_name

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :role
  end
end
