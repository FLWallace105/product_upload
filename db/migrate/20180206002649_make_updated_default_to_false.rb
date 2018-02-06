class MakeUpdatedDefaultToFalse < ActiveRecord::Migration[5.1]
  def change
    change_column_default :marika_products, :updated, false
  end
end
