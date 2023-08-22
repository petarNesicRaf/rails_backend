class ChangeColumnTypeInMovies < ActiveRecord::Migration[7.0]
  def change
    change_column :movies, :year, :string
  end
end
