class RemoveAuthorFromAnimes < ActiveRecord::Migration[7.0]
  def change
    remove_column :animes, :author, :string
  end
end
