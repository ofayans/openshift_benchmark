class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :tag
      t.string :uuid

      t.timestamps
    end
  end
end
