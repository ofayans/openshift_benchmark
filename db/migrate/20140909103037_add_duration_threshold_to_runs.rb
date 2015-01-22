class AddDurationThresholdToRuns < ActiveRecord::Migration
  def change
    add_column :runs, :duration_threshold, :integer
  end
end
