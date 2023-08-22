class CreateAnimes < ActiveRecord::Migration[7.0]
  def change
    create_table :animes do |t|
      t.string :title
      t.string :author
      t.string :studio
      t.integer :year
      t.integer :chapters
      t.integer :episodes
      t.integer :seasons

      t.timestamps
    end
  end
end
