class AddAuthorToAnime < ActiveRecord::Migration[7.0]
  def change
    add_reference :animes, :author
  end
end
