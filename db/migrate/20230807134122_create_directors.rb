class CreateDirectors < ActiveRecord::Migration[7.0]
  def change
    create_table :directors do |t|
      t.string :first_name
      t.string :last_name
      t.string :nationality
      t.integer :age

      t.timestamps
    end
  end
end
