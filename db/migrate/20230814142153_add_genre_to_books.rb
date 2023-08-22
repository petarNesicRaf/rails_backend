class AddGenreToBooks < ActiveRecord::Migration[7.0]
  def change
    add_reference :books, :genre
  end
end
