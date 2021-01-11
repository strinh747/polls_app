class CreatePolls < ActiveRecord::Migration[5.2]
  def change
    create_table :polls do |t|
      t.string :title
      t.integer :user_id

      t.timestamps
    end

    add_index :polls, :title, unique: true
    add_index :polls, :user_id
  end
end
