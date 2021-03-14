class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :uid
      t.string :provider
      t.string :name
      t.string :image

      t.timestamps
    end
  end
end
