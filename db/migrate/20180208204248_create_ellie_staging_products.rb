class CreateEllieStagingProducts < ActiveRecord::Migration[5.1]
  def change
    create_table :ellie_staging_products do |t|
      t.string :shopify_product_id
      t.string :title
      t.text :body_html
      t.boolean :updated, default: false
      t.string :handle

      t.timestamps
    end
  end
end
