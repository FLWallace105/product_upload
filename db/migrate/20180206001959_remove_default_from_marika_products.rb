class RemoveDefaultFromMarikaProducts < ActiveRecord::Migration[5.1]
  def change
    change_column_default :marika_products, :status, nil
  end
end
