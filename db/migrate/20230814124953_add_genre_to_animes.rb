class AddGenreToAnimes < ActiveRecord::Migration[7.0]
  def change
    add_reference :animes, :genre
  end
end
