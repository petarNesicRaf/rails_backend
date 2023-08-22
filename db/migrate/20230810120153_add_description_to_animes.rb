class AddDescriptionToAnimes < ActiveRecord::Migration[7.0]
  def change
    add_column :animes, :description, :string
  end
end
