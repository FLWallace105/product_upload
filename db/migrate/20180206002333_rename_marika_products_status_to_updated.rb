class RenameMarikaProductsStatusToUpdated < ActiveRecord::Migration[5.1]
  def change
    rename_column :marika_products, :status, :updated
  end
end
