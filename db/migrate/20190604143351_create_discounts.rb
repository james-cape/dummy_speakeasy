class CreateDiscounts < ActiveRecord::Migration[5.1]
  def change
    create_table :discounts do |t|
      t.float :discount_amount
      t.integer :minimum_quantity
      t.string :description
      t.references :user, foreign_key: true
    end
  end
end
