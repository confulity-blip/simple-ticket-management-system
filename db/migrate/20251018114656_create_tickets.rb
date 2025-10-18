class CreateTickets < ActiveRecord::Migration[7.1]
  def change
    create_table :tickets do |t|
      t.string :ticket_key, null: false
      t.string :title, null: false
      t.text :description
      t.integer :status, null: false, default: 0  # 0=new, 1=open, 2=pending, 3=resolved, 4=closed
      t.integer :priority, null: false, default: 1  # 0=low, 1=medium, 2=high, 3=urgent
      t.string :category
      t.string :subcategory
      t.references :requester, null: false, foreign_key: { to_table: :users }
      t.references :assignee, null: true, foreign_key: { to_table: :users }
      t.datetime :first_response_at
      t.datetime :resolved_at
      t.datetime :closed_at

      t.timestamps
    end

    add_index :tickets, :ticket_key, unique: true
    add_index :tickets, :status
    add_index :tickets, :priority
    add_index :tickets, :category
    add_index :tickets, :created_at
  end
end
