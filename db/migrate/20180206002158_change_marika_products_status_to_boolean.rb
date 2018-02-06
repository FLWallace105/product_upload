class ChangeMarikaProductsStatusToBoolean < ActiveRecord::Migration[5.1]
  def change
    change_column :marika_products, :status, 'boolean USING CAST(status AS boolean)'
  end
end
