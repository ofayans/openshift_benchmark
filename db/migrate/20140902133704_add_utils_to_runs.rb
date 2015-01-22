class AddUtilsToRuns < ActiveRecord::Migration
  def change
    add_column :runs, :util_id, :integer
  end
end
