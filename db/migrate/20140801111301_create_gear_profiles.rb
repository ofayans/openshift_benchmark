class CreateGearProfiles < ActiveRecord::Migration
  def change
    create_table :gear_profiles do |t|
      t.string :name

      t.timestamps
    end
  end
end
