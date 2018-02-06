class ChangeZobhaStatusToBooleanAndChangeNameToUpdated < ActiveRecord::Migration[5.1]
  def change
    change_column_default :zobha_products, :status, nil
    change_column :zobha_products, :status, 'boolean USING CAST(status AS boolean)'
    rename_column :zobha_products, :status, :updated
    change_column_default :zobha_products, :updated, false
  end
end
