class CreateCommands < ActiveRecord::Migration[6.1]
  def change
    create_table :commands do |t|
      t.string :name
      t.references :meme, null: false, foreign_key: true

      t.timestamps
    end
  end
end
