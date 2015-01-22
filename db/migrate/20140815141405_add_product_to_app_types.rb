class AddProductToAppTypes < ActiveRecord::Migration
  def change
    add_column :app_types, :references, :products
  end
end
