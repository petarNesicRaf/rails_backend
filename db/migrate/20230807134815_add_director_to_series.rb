class AddDirectorToSeries < ActiveRecord::Migration[7.0]
  def change
    add_reference :series, :director
  end
end
