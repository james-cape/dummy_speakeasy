class CreateAddresses < ActiveRecord::Migration[5.1]
  def change
    create_table :addresses do |t|
      t.references :user, foreign_key: true
      t.string :nickname
      t.string :street
      t.string :city
      t.string :state
      t.string :zip_code
    end
  end
end
