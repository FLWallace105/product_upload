class CreateEllieProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :ellie_products do |t|
      t.string :shopify_product_id
      t.string :title
      t.text :body_html
      t.boolean :updated, default: false
      t.string :handle

      t.timestamps
    end
  end
end
