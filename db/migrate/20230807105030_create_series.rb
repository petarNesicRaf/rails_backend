class CreateSeries < ActiveRecord::Migration[7.0]
  def change
    create_table :series do |t|
      t.string :title
      t.string :director
      t.integer :year
      t.integer :episodes
      t.integer :seasons

      t.timestamps
    end
  end
end
