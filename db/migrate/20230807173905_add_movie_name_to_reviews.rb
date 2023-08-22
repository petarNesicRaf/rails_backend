class AddMovieNameToReviews < ActiveRecord::Migration[7.0]
  def change
    add_column :reviews, :movie_name, :string
  end
end
