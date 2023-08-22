class AddPagesToBooks < ActiveRecord::Migration[7.0]
  def change
    add_column :books, :pages, :integer
  end
end
