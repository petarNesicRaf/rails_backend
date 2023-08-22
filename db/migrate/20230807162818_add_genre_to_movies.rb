class AddGenreToMovies < ActiveRecord::Migration[7.0]
  def change
    add_reference :movies, :genre
  end
end
