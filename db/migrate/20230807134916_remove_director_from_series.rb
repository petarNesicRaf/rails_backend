class RemoveDirectorFromSeries < ActiveRecord::Migration[7.0]
  def change
    remove_column :series, :director, :string
  end
end
