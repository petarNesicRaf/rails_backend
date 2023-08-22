class AddDirectorToMovies < ActiveRecord::Migration[7.0]
  def change
    add_reference :movies, :director
  end
end
