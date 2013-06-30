class AddTokenToPages < ActiveRecord::Migration
  def change
    add_column :pages, :token, :string, :limit => 32
    add_index :pages, :token
  end
end
