class CreateMarikaProducts < ActiveRecord::Migration[5.1]
  def change
    create_table :marika_products do |t|
      t.string :shopify_product_id
      t.text :body_html
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
