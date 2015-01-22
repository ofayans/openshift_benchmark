class CreateDockerservers < ActiveRecord::Migration
  def change
    create_table :dockerservers do |t|
      t.string :name
      t.string :url

      t.timestamps
    end
  end
end
