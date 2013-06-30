class AddPageIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :page_id, :integer
    add_index :users, :page_id
  end
end
