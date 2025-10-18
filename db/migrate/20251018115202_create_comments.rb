class CreateComments < ActiveRecord::Migration[7.1]
  def change
    create_table :comments do |t|
      t.references :ticket, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :body, null: false
      t.boolean :public, null: false, default: true

      t.timestamps
    end

    add_index :comments, [:ticket_id, :created_at]
    add_index :comments, :public
  end
end
