class CreateZobhaProducts < ActiveRecord::Migration[5.1]
  def change
    create_table :zobha_products do |t|
      t.string :shopify_product_id
      t.string :title
      t.text :body_html
      t.integer :status, default: 0
      t.string :handle

      t.timestamps
    end
  end
end
