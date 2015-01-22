class CreateRundockerservers < ActiveRecord::Migration
  def change
    create_table :rundockerservers do |t|
      t.references :run, index: true
      t.references  :dockerserver, index: true
      t.references  :image, index: true
      t.integer  "jobcount"
      t.timestamps
    end
  end
end
