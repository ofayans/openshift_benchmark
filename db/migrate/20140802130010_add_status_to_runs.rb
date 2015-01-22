class AddStatusToRuns < ActiveRecord::Migration
  def change
    add_reference :runs, :status, index: true
  end
end
